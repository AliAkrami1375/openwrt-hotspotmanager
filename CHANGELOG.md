# Changelog

## 1.0.0-1 — 2026-10-08

First packaged release (architecture independent).

- Captive portal under a clean hostname with Persian/English UI, Dibachain branding, CPD support
- Users, profiles, vouchers, bypass devices; data/speed/time limits, MAC cookie, shared devices
- Site & app filter (global/profile/user) with built-in categories, throttling, daily per-site
  quotas, per-connection download cap, block page for HTTP and HTTPS, DNS enforcement
- Auto-detected Passwall2 / Passwall integration: per user "Passwall / direct" route,
  domains that never use the VPN, mirrored bypass sets that survive Passwall restarts
- Policy routing through any interface, upstream proxies (node / SOCKS5 / HTTP / Shadowsocks /
  VLESS / VMess / Trojan / raw xray JSON) and SOCKS5/HTTP proxy servers on the router
- Managed Xray VLESS+REALITY nodes installed from LuCI, reverse SSH tunnels, port forwards
- Per-user live monitor (rates, sessions, daily usage, DNS activity, connections)
- Self-service passwords (first-login prompt, change page)
- Gap-free configuration reload, capabilities probe, universal installer for opkg and apk
