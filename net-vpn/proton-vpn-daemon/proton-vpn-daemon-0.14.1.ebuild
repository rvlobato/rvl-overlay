# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_SINGLE_IMPL=1
DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1 systemd

DESCRIPTION="Proton VPN daemon (split tunneling service)"
HOMEPAGE="https://github.com/ProtonVPN/proton-vpn-daemon"
SRC_URI="https://github.com/ProtonVPN/proton-vpn-daemon/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64"
RESTRICT="test"

RDEPEND="
	$(python_gen_cond_dep '
		dev-python/dbus-fast[${PYTHON_USEDEP}]
		dev-python/packaging[${PYTHON_USEDEP}]
		dev-python/psutil[${PYTHON_USEDEP}]
		>=dev-python/proton-vpn-api-core-6.0.0[${PYTHON_USEDEP}]
	')
	dev-util/bcc[python,${PYTHON_SINGLE_USEDEP}]
	net-vpn/wireguard-tools
	sys-apps/dbus
"

# Use tracepoints instead of kprobes, which bcc no longer attaches to
# the execve syscall wrappers (same patch as used by Arch Linux).
PATCHES=(
	"${FILESDIR}/${P}-bcc-tracepoints.patch"
)

src_install() {
	distutils-r1_src_install

	# The module is installed for the selected Python only,
	# so the unit must not use a generic python3.
	sed -e "s|/usr/bin/python3|${PYTHON}|" \
		rpmbuild/SOURCES/systemd.service > "${T}/proton.VPN.service" || die
	systemd_dounit "${T}/proton.VPN.service"

	insinto /usr/share/dbus-1/system.d
	newins rpmbuild/SOURCES/dbus.conf me.proton.vpn.split_tunneling.conf
	insinto /usr/share/dbus-1/system-services
	newins rpmbuild/SOURCES/dbus.service me.proton.vpn.split_tunneling.service
}
