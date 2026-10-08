<div dir="rtl">

# Dibachain Hotspot User Manager — بستهٔ نصبی برای OpenWrt

این مخزن فقط **بسته‌های آمادهٔ نصب** را نگه می‌دارد. سورس، مستندات کامل و معماری در مخزن اصلی است:
**[dibachain-openwrt-usermanager](https://github.com/AliAkrami1375/dibachain-openwrt-usermanager)**

هات‌اسپات حرفه‌ای به سبک MikroTik User Manager: پورتال ورود برنددار، کاربر/پروفایل/ووچر، حجم و سرعت و اعتبار، فیلتر سایت و اپ با دسته‌های آماده، سهمیهٔ روزانهٔ هر سایت، مسیر اینترنت (Passwall یا مستقیم؛ **خودکار تشخیص داده می‌شود**)، Policy Routing، پراکسی‌های upstream و پراکسی‌سرور روی روتر، نودهای REALITY مدیریت‌شده، تونل معکوس، پورت‌فوروارد و مانیتورینگ زندهٔ هر کاربر.

## سازگاری

| | |
|---|---|
| OpenWrt | **23.05 و 24.10** (opkg) و اسنپ‌شات‌ها/25.x (apk) — نیاز به fw4/nftables و LuCI جدید (JS) |
| معماری | **all** (ucode + JavaScript + shell؛ روی هر CPU کار می‌کند) |
| تست‌شده روی | OpenWrt 24.10.3 / Linksys EA8300 (ipq40xx) با و بدون Passwall2 |
| پشتیبانی‌نشده | 22.03 و قدیمی‌تر (dnsmasq بدون nftset، LuCI قدیمی) |

وابستگی‌های اختیاری که **خودکار تشخیص داده می‌شوند** (در Overview → Capabilities):
- **Passwall2 / Passwall**: اگر باشد، گزینه‌های «مسیر Passwall / مستقیم»، «سایت‌های بدون VPN» و بای‌پس‌ها فعال می‌شوند؛ اگر نباشد همه چیز مثل یک روتر عادی کار می‌کند.
- **xray-core**: برای پراکسی‌های upstream، پراکسی‌سرور روتر و نودها (`opkg install xray-core` یا با Passwall2 می‌آید).
- **dnsmasq-full**: برای قوانین دامنه‌ای (فیلتر، سهمیهٔ سایت، سایت‌های مستقیم). نصب‌کننده خودش `dnsmasq` را با `dnsmasq-full` عوض می‌کند.
- **uhttpd-mod-tls / libustream**: صفحهٔ بلاک برای سایت‌های HTTPS.

## نصب

**روش ۱ — نصب‌کنندهٔ یکپارچه (پیشنهادی، opkg و apk):** روی روتر:

</div>

```sh
cd /tmp
wget -O install.sh https://github.com/AliAkrami1375/openwrt-hotspotmanager/raw/main/install.sh
sh install.sh                # وابستگی‌ها را نصب و بسته را راه‌اندازی می‌کند
sh install.sh --with-xray    # + نصب xray-core برای قابلیت‌های پراکسی
```

<div dir="rtl">

**روش ۲ — فایل ipk:**

</div>

```sh
cd /tmp
wget https://github.com/AliAkrami1375/openwrt-hotspotmanager/raw/main/luci-app-hotspotmanager_1.0.0-1_all.ipk
opkg update && opkg install luci-app-hotspotmanager_1.0.0-1_all.ipk
# برای قوانین دامنه‌ای:
opkg remove dnsmasq && opkg install dnsmasq-full && /etc/init.d/dnsmasq restart
```

<div dir="rtl">

بعد از نصب: **LuCI → Services → Hotspot User Manager**. اگر منو نیامد یک بار از LuCI خارج و دوباره وارد شوید.

> ⚠️ **قبل از اعتماد به هات‌اسپات، MAC کامپیوتر مدیریت را در تب Bypass اضافه کنید**، یا گزینهٔ «Allow router admin without login» را روشن نگه دارید؛ وگرنه دسترسی خودتان به LuCI/SSH هم پشت پورتال می‌رود.

## به‌روزرسانی

</div>

```sh
sh install.sh            # یا: opkg install --force-reinstall luci-app-hotspotmanager_<ver>_all.ipk
```

<div dir="rtl">

کانفیگ (`/etc/config/usermanager`) و آمار کاربران (`/etc/usermanager/`) حفظ می‌شوند؛ نشست‌های فعال قطع نمی‌شوند.

## حذف

</div>

```sh
sh install.sh --uninstall        # یا: opkg remove luci-app-hotspotmanager
```

<div dir="rtl">

## بررسی صحت فایل‌ها

`sha256sums` در همین مخزن؛ `sha256sum -c sha256sums`.

## فایل‌ها

| فایل | توضیح |
|---|---|
| `luci-app-hotspotmanager_<ver>_all.ipk` | بستهٔ opkg (معماری all) |
| `hotspotmanager-<ver>.tar.gz` | payload بسته برای نصب‌کنندهٔ یکپارچه (و سیستم‌های apk) |
| `install.sh` | نصب‌کننده/حذف‌کنندهٔ یکپارچه |
| `sha256sums` | چک‌سام‌ها |
| `CHANGELOG.md` | تغییرات نسخه‌ها |

## مجوز

Apache-2.0 — © 2026 Dibachain

</div>
