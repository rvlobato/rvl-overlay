# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_SINGLE_IMPL=true
DISTUTILS_USE_PEP517=setuptools

PYTHON_COMPAT=( python3_{12..14} )

inherit desktop distutils-r1 xdg

DESCRIPTION="Proton VPN GTK app"
HOMEPAGE="https://github.com/ProtonVPN/proton-vpn-gtk-app"
SRC_URI="https://github.com/ProtonVPN/proton-vpn-gtk-app/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-3+"
SLOT="0"
KEYWORDS="~amd64"
RESTRICT="test"

RDEPEND="
	$(python_gen_cond_dep '
		dev-python/dbus-python[${PYTHON_USEDEP}]
		dev-python/distro[${PYTHON_USEDEP}]
		dev-python/packaging[${PYTHON_USEDEP}]
		dev-python/proton-core[${PYTHON_USEDEP}]
		dev-python/proton-keyring-linux[${PYTHON_USEDEP}]
		>=dev-python/proton-vpn-api-core-6.0.0[${PYTHON_USEDEP}]
		dev-python/pycairo[${PYTHON_USEDEP}]
		dev-python/pygobject[${PYTHON_USEDEP}]
		dev-python/requests[${PYTHON_USEDEP}]
	')
	gui-libs/gtk:4[introspection]
	gui-libs/libadwaita:1[introspection]
	net-vpn/proton-vpn-daemon
	x11-libs/gdk-pixbuf:2[introspection]
	x11-libs/libnotify[introspection]
	x11-libs/pango[introspection]
"
# msgfmt compiles the translations in setup.py
BDEPEND="sys-devel/gettext"

src_install() {
	distutils-r1_src_install

	doicon -s scalable rpmbuild/SOURCES/proton-vpn-logo.svg
	doicon -s scalable proton/vpn/app/gtk/assets/icons/proton-vpn-sign.svg
	domenu rpmbuild/SOURCES/proton.vpn.app.gtk.desktop
}
