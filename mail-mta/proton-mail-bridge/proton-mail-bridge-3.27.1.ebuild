# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake desktop go-env go-module systemd xdg-utils

MY_PN="${PN/-mail/}"
MY_P="${MY_PN}-${PV}"

DESCRIPTION="Serves Proton Mail to IMAP/SMTP clients"
HOMEPAGE="https://proton.me/mail/bridge https://github.com/ProtonMail/proton-bridge/"
SRC_URI="https://github.com/ProtonMail/${MY_PN}/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz
	https://github.com/rvlobato/rvl-overlay/releases/download/${P}/${P}-vendor.tar.xz"
S="${WORKDIR}"/${MY_P}

LICENSE="GPL-3+ Apache-2.0 BSD BSD-2 ISC LGPL-3+ MIT MPL-2.0 Unlicense"
SLOT="0"
KEYWORDS="~amd64"
IUSE="gui"

# Quite a few tests require Internet access
PROPERTIES="test_network"
RESTRICT="test"

# libfido2 is linked by the Go part (FIDO2 security key login) since 3.22.
RDEPEND="
	app-crypt/libsecret
	dev-db/sqlite:3
	dev-libs/libcbor:=
	dev-libs/libfido2:=
	dev-libs/openssl:=
	gui? (
		>=dev-libs/protobuf-21.12:=
		dev-libs/re2:=
		>=dev-libs/sentry-native-0.6.5-r1
		dev-qt/qtbase:6=[gui,icu,widgets]
		dev-qt/qtdeclarative:6=[widgets]
		dev-qt/qtsvg:6=
		media-libs/mesa
		net-libs/grpc:=
	)
"
DEPEND="${RDEPEND}"
BDEPEND=">=dev-lang/go-1.26.1:="

PATCHES=(
	"${FILESDIR}"/${P}-gui_gentoo.patch
	"${FILESDIR}"/${P}-wayland-icon.patch
)

# $S is there for bug 957684
DOCS=( "${S}"/{README,Changelog}.md )

src_unpack() {
	default

	if [[ -d "${WORKDIR}"/vendor ]]; then # if we ship the dependencies
		mv "${WORKDIR}"/vendor "${S}"/vendor || die # move them into the tree
	fi

	go-env_set_compile_environment
}

src_prepare() {
	xdg_environment_reset
	default
	if use gui; then
		# prepare desktop file
		local desktopFilePath="${S}"/dist/${MY_PN}.desktop
		sed -i 's/protonmail/proton-mail/g' ${desktopFilePath} || die
		sed -i 's/Exec=proton-mail-bridge/Exec=proton-mail-bridge-gui/g' ${desktopFilePath} || die

		# build GUI
		local PATCHES=()
		BUILD_DIR="${WORKDIR}"/gui_build \
			CMAKE_USE_DIR="${S}"/internal/frontend/bridge-gui/bridge-gui \
			cmake_src_prepare
	fi
}

src_configure() {
	if use gui; then
		local mycmakeargs=(
			-DBRIDGE_APP_FULL_NAME="Proton Mail Bridge"
			-DBRIDGE_APP_VERSION="${PV}+git"
			-DBRIDGE_REPO_ROOT="${S}"
			-DBRIDGE_TAG="NOTAG"
			-DBRIDGE_VENDOR="Gentoo Linux"
			-DCMAKE_DISABLE_PRECOMPILE_HEADERS=OFF
		)
		BUILD_DIR="${WORKDIR}"/gui_build \
			CMAKE_USE_DIR="${S}"/internal/frontend/bridge-gui/bridge-gui \
			cmake_src_configure
	fi
}

src_compile() {
	# The Makefile overrides CGO_LDFLAGS with LIBFIDO2_LDFLAGS; keep the
	# user's LDFLAGS. Link against system sqlite instead of the bundled copy.
	# BUILD_ENV must not contain spaces: it ends up unquoted in -ldflags.
	emake -Onone \
		BUILD_ENV="gentoo" \
		BUILD_TAGS="libsqlite3" \
		LIBFIDO2_LDFLAGS="${CGO_LDFLAGS} -lfido2 -lcbor -lssl -lcrypto" \
		build-nogui

	if use gui; then
		BUILD_DIR="${WORKDIR}"/gui_build \
			CMAKE_USE_DIR="${S}"/internal/frontend/bridge-gui/bridge-gui \
			cmake_src_compile
	fi
}

src_test() {
	emake -Onone test
}

src_install() {
	exeinto /usr/bin
	newexe bridge ${PN}

	if use gui; then
		BUILD_DIR="${WORKDIR}"/gui_build \
			CMAKE_USE_DIR="${S}"/internal/frontend/bridge-gui/bridge-gui \
			cmake_src_install
		mv "${ED}"/usr/bin/bridge-gui "${ED}"/usr/bin/${PN}-gui || die
		newicon {"${S}"/dist/bridge,${PN}}.svg
		newmenu {dist/${MY_PN},${PN}}.desktop
	fi

	systemd_newuserunit "${FILESDIR}"/${PN}.service-r1 ${PN}.service

	einstalldocs
}

pkg_postinst() {
	xdg_desktop_database_update
	xdg_icon_cache_update
}

pkg_postrm() {
	xdg_desktop_database_update
	xdg_icon_cache_update
}
