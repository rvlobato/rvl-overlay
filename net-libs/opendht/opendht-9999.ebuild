# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="Free and universal communication platform which preserves the users’ privacy and freedoms (daemon component)"

HOMEPAGE="https://github.com/savoirfairelinux/opendht"
LICENSE="GPL-3"
SLOT="0"
IUSE=""

inherit git-r3
EGIT_REPO_URI="https://github.com/savoirfairelinux/opendht.git"

RDEPEND="
	app-crypt/argon2
	dev-libs/libfmt
	sys-libs/glibc
	net-libs/gnutls
	net-libs/http-parser
	dev-libs/jsoncpp
	dev-libs/nettle
	dev-libs/openssl
	sys-libs/readline
"

DEPEND="${RDEPEND}"
