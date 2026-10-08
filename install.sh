#!/bin/sh
# ------------------------------------------------------------------------------
#  Dibachain Hotspot User Manager - universal installer for OpenWrt
#
#  Works on opkg based releases (23.05, 24.10) and apk based snapshots/25.x.
#  Run ON THE ROUTER:
#     sh install.sh                 (uses hotspotmanager-1.0.0.tar.gz next to it, or downloads it)
#     sh install.sh --with-xray     (also install xray-core for the proxy features)
#     sh install.sh --uninstall
# ------------------------------------------------------------------------------
set -e
VER="1.0.0"
BASE_URL="https://github.com/AliAkrami1375/openwrt-hotspotmanager/raw/main"
TARBALL="hotspotmanager-$VER.tar.gz"
WITH_XRAY=0; UNINSTALL=0
for a in "$@"; do case "$a" in --with-xray) WITH_XRAY=1;; --uninstall) UNINSTALL=1;; esac; done

say()  { printf '\033[32m[*]\033[0m %s\n' "$*"; }
warn() { printf '\033[33m[!]\033[0m %s\n' "$*"; }
die()  { printf '\033[31m[x]\033[0m %s\n' "$*" >&2; exit 1; }

[ "$(id -u)" = 0 ] || die "run as root on the OpenWrt router"
[ -f /etc/openwrt_release ] || die "this does not look like OpenWrt"
. /etc/openwrt_release
say "OpenWrt $DISTRIB_RELEASE ($DISTRIB_TARGET)"

if command -v opkg >/dev/null 2>&1; then PM=opkg; elif command -v apk >/dev/null 2>&1; then PM=apk; else die "no opkg/apk found"; fi
pm_update()  { if [ $PM = opkg ]; then opkg update >/dev/null 2>&1 || warn "opkg update failed (offline?)"; else apk update >/dev/null 2>&1 || warn "apk update failed"; fi; }
pm_has()     { if [ $PM = opkg ]; then opkg list-installed | grep -q "^$1 "; else apk info -e "$1" >/dev/null 2>&1; fi; }
pm_install() { for p in "$@"; do pm_has "$p" && continue; say "installing $p"; if [ $PM = opkg ]; then opkg install "$p" >/dev/null 2>&1 || warn "could not install $p"; else apk add "$p" >/dev/null 2>&1 || warn "could not install $p"; fi; done; }

if [ "$UNINSTALL" = 1 ]; then
	say "stopping service"
	/etc/init.d/usermanager stop 2>/dev/null || true
	/etc/init.d/usermanager disable 2>/dev/null || true
	if pm_has luci-app-hotspotmanager; then
		[ $PM = opkg ] && opkg remove luci-app-hotspotmanager || apk del luci-app-hotspotmanager
	else
		rm -rf /usr/share/ucode/usermanager /usr/share/rpcd/ucode/usermanager.uc /usr/share/rpcd/acl.d/luci-app-usermanager.json \
			/usr/share/luci/menu.d/luci-app-usermanager.json /www/luci-static/resources/usermanager /www/luci-static/resources/view/usermanager \
			/www/usermanager-portal /usr/sbin/usermanagerd /usr/sbin/usermanagerctl /etc/init.d/usermanager /usr/share/usermanager
	fi
	rm -rf /tmp/luci-indexcache* /tmp/luci-modulecache; /etc/init.d/rpcd restart
	warn "kept /etc/config/usermanager and /etc/usermanager (usage data). Delete them manually if you want a clean slate."
	say "uninstalled"; exit 0
fi

# ---- requirements --------------------------------------------------------------
MAJOR="${DISTRIB_RELEASE%%.*}"; MINOR="$(echo "$DISTRIB_RELEASE" | cut -d. -f2)"
case "$DISTRIB_RELEASE" in
	SNAPSHOT|snapshot) ;;
	*) if [ "${MAJOR:-0}" -lt 23 ] 2>/dev/null; then die "OpenWrt 23.05 or newer is required (fw4/nftables, dnsmasq with nftset, LuCI JS). Found $DISTRIB_RELEASE"; fi;;
esac
command -v nft >/dev/null 2>&1 || die "nftables (fw4) is required"
[ -x /usr/sbin/fw4 ] || [ -x /sbin/fw4 ] || warn "fw4 not found; the hotspot needs firewall4"

pm_update
pm_install luci-base rpcd rpcd-mod-ucode ucode ucode-mod-fs ucode-mod-uci ucode-mod-ubus ucode-mod-uloop liblucihttp-ucode uhttpd nftables kmod-nft-nat

# dnsmasq-full gives nftset support (domain based filters, direct domains, site quotas)
if ! dnsmasq --version 2>/dev/null | grep -q '[^-]nftset'; then
	say "switching dnsmasq -> dnsmasq-full (needed for domain based rules)"
	if [ $PM = opkg ]; then
		cp /etc/config/dhcp /tmp/dhcp.bak
		opkg remove dnsmasq >/dev/null 2>&1 || true
		opkg install dnsmasq-full >/dev/null 2>&1 || warn "dnsmasq-full installation failed; domain based features will be inactive"
		[ -s /etc/config/dhcp ] || cp /tmp/dhcp.bak /etc/config/dhcp
	else
		apk add dnsmasq-full >/dev/null 2>&1 || warn "dnsmasq-full installation failed"
	fi
	/etc/init.d/dnsmasq restart >/dev/null 2>&1 || true
fi
# TLS for the HTTPS block page (uhttpd's https listener) - optional
pm_install uhttpd-mod-tls 2>/dev/null || true
[ "$WITH_XRAY" = 1 ] && pm_install xray-core

# ---- payload -------------------------------------------------------------------
HERE="$(cd "$(dirname "$0")" && pwd)"
if [ ! -f "$HERE/$TARBALL" ]; then
	say "downloading $TARBALL"
	( cd /tmp && { curl -fsSL -o "$TARBALL" "$BASE_URL/$TARBALL" || wget -q -O "$TARBALL" "$BASE_URL/$TARBALL"; } ) || die "download failed; put $TARBALL next to install.sh"
	HERE=/tmp
fi
KEEP_CFG=0; [ -f /etc/config/usermanager ] && { cp /etc/config/usermanager /tmp/usermanager.cfg.keep; KEEP_CFG=1; }
say "installing files"
tar xzf "$HERE/$TARBALL" -C /
[ "$KEEP_CFG" = 1 ] && { cp /tmp/usermanager.cfg.keep /etc/config/usermanager; say "kept existing configuration"; }
chmod 600 /etc/config/usermanager
sh /etc/uci-defaults/99-hotspotmanager && rm -f /etc/uci-defaults/99-hotspotmanager
/etc/init.d/usermanager enable
/etc/init.d/usermanager restart
sleep 2
say "status:"; /usr/sbin/usermanagerctl status 2>/dev/null | grep -E '"(running|firewall|passwall|portal_url)"' || true
cat <<EOF

Installed Dibachain Hotspot User Manager $VER.
  LuCI  : Services -> Hotspot User Manager
  Portal: http://$(uci -q get usermanager.settings.portal_host || echo dibachain.router)

IMPORTANT: add the MAC of the computer you manage the router from to the Bypass list
before relying on the hotspot, or keep "Allow router admin without login" enabled.
EOF
