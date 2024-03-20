# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="OpenDHT: a C++17 Distributed Hash Table implementation"

HOMEPAGE="https://github.com/savoirfairelinux/opendht/"
SRC_URI="https://github.com/savoirfairelinux/opendht/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64"

inherit meson

DEPEND="
	net-libs/gnutls
	dev-libs/nettle
	dev-cpp/msgpack-cxx
	app-crypt/argon2
	dev-libs/openssl
	dev-libs/jsoncpp
	dev-libs/libfmt
"

RDEPEND="${DEPEND}"
BDEPEND="
	dev-cpp/msgpack-cxx
	dev-cpp/asio
"
