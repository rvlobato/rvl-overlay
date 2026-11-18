# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit desktop unpacker xdg

MY_PN="${PN%-bin}"

DESCRIPTION="Feature-rich native desktop YouTube Music client (Tauri)"
HOMEPAGE="https://github.com/SimoHypers/limusic"
SRC_URI="https://github.com/SimoHypers/${MY_PN}/releases/download/v${PV}/${MY_PN}_${PV}_amd64.deb"
S="${WORKDIR}"

# The binary statically bundles many Rust crates and deno_core/V8.
LICENSE="GPL-3 Apache-2.0 BSD MIT MPL-2.0 ISC Unicode-3.0"
SLOT="0"
KEYWORDS="-* ~amd64"

# Linked libraries of usr/bin/limusic-app (readelf -d), plus
# libayatana-appindicator3, which the tray icon dlopen()s at runtime.
RDEPEND="
	dev-libs/glib:2
	dev-libs/libayatana-appindicator
	dev-libs/openssl:0/3
	media-video/mpv[libmpv]
	net-libs/libsoup:3.0
	net-libs/webkit-gtk:4.1
	sys-apps/dbus
	>=sys-libs/glibc-2.39
	x11-libs/cairo
	x11-libs/gdk-pixbuf:2
	x11-libs/gtk+:3
"

QA_PREBUILT="usr/bin/limusic-app"

src_install() {
	dobin usr/bin/limusic-app
	dosym limusic-app /usr/bin/${MY_PN}

	local size
	for size in 32 64 128 512; do
		doicon -s ${size} usr/share/icons/hicolor/${size}x${size}/apps/limusic-app.png
	done

	domenu usr/share/applications/limusic.desktop
}

pkg_postinst() {
	xdg_pkg_postinst

	elog "The built-in updater cannot update a Portage-managed install;"
	elog "update through emerge instead."
	elog
	elog "On nouveau, WebKitGTK's DMA-BUF renderer may show a blank or red"
	elog "window. Start it with WEBKIT_DISABLE_DMABUF_RENDERER=1 in that case."
}
