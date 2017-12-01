# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="2"

inherit autotools multilib

MY_PV=${PV/_/}
MY_P="vuurmuur-${MY_PV}"

DESCRIPTION="Libraries and plugins required by Vuurmuur"
HOMEPAGE="http://www.vuurmuur.org"
SRC_URI="ftp://ftp.vuurmuur.org/releases/${MY_PV}/${MY_P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND="net-firewall/iptables[ipv6]
        net-libs/libnetfilter_log"
RDEPEND="${DEPEND}"

S="${WORKDIR}/${MY_P}/${PN}-${MY_PV}"

src_unpack() {
	default
	cd "${MY_P}"
	unpack "./libvuurmuur-${MY_PV}.tar.gz"
}

src_configure() {
	econf --with-plugindir=/usr/$(get_libdir)
}

src_install() {
	emake DESTDIR="${D}" install || die "installing libvuurmuur failed"

	# files needed but not yet installed by make
	dodir /etc/vuurmuur/textdir || die "installing textdir failed"
	dodir /etc/vuurmuur/plugins || die "installing plugins failed"
	insinto /etc/vuurmuur/plugins
	doins "${FILESDIR}"/textdir.conf || die "installing textdir.conf failed"
}
