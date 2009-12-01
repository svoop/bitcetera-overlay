# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit autotools

EAPI="2"

MY_PN="Vuurmuur"
MY_PV=${PV/_beta/beta}

DESCRIPTION="Libraries and plugins needed by Vuurmuur."
HOMEPAGE="http://www.vuurmuur.org"
SRC_URI="ftp://ftp.vuurmuur.org/releases/${MY_PV}/${MY_PN}-${MY_PV}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ppc ~x86"
IUSE=""

RDEPEND="net-firewall/iptables"

S="${WORKDIR}/${MY_PN}-${MY_PV}/${PN}-${MY_PV}"

src_unpack() {
	unpack ${A} || die "unpacking failed"
	cd "${MY_PN}-${MY_PV}"
	tar xzf libvuurmuur-${MY_PV}.tar.gz || die "unpacking component failed"
}

src_prepare() {
	epatch "${FILESDIR}"/libvuurmuur-plugin-0.7.patch   # no longer needed as of >0.8_beta2
	eautoreconf || die "eautoreconf failed"
}

src_configure() {
	econf \
		--with-plugindir=/usr/lib \
		--with-shareddir=/usr/share \
		|| die "econf failed"
}

src_compile() {
	emake || die "emake failed"
}

src_install() {
	einstall

	dodir /etc/vuurmuur/textdir
	insinto /etc/vuurmuur/plugins
	doins plugins/textdir/textdir.conf
}
