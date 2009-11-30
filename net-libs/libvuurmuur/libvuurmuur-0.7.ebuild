# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit autotools

EAPI="2"

MY_PN="Vuurmuur"

DESCRIPTION="Libraries and plugins needed by Vuurmuur."
HOMEPAGE="http://www.vuurmuur.org"
SRC_URI="mirror://sourceforge/vuurmuur/${MY_PN}-${PV}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ppc ~x86"
IUSE=""

RDEPEND="net-firewall/iptables"

S="${WORKDIR}/${MY_PN}-${PV}"

src_unpack() {
	unpack ${A} || die "unpacking failed"
	cd "${S}"
	tar xzf libvuurmuur-${PV}.tar.gz || die "unpacking component failed"
}

src_prepare() {
	epatch "${FILESDIR}"/libvuurmuur-plugin-0.7.patch
	cd "${S}/libvuurmuur-${PV}"
	if ! [ -d m4 ]; then mkdir m4; fi   # workaround for upstream issue
	eautoreconf || die "eautoreconf failed"
}

src_configure() {
	cd "${S}/libvuurmuur-${PV}"
	econf \
		--with-plugindir=/usr/lib/vuurmuur \
		--with-shareddir=/usr/share/vuurmuur \
		|| die "econf failed"
}

src_compile() {
	cd "${S}/libvuurmuur-${PV}"
	emake || die "emake failed"
}

src_install() {
	cd "${S}/libvuurmuur-${PV}"
	einstall
}