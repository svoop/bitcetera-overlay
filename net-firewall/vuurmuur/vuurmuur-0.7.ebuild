# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit autotools

EAPI="2"

MY_PN="Vuurmuur"

DESCRIPTION="Frontend for iptables featuring easy to use command line utils, rule- and logdaemons."
HOMEPAGE="http://www.vuurmuur.org"
SRC_URI="mirror://sourceforge/vuurmuur/${MY_PN}-${PV}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ppc ~x86"
IUSE="logrotate"

RDEPEND="net-firewall/iptables
	>=sys-libs/ncurses-5
	logrotate? ( app-admin/logrotate )"

S="${WORKDIR}/${MY_PN}-${PV}/${P}"

src_unpack() {
	unpack ${A} || die "unpacking failed"
	cd ${MY_PKG_NAME}-${PV} || die "changing directory failed"
	einfo "Unpacking ${P}.tar.gz"
	gzip -cd ${P}.tar.gz | tar xf - || die "Unpacking of ${P}.tar.gz failed"
}

src_prepare() {
	epatch "${FILESDIR}"/libvuurmuur-plugin-0.7.patch
	eautoreconf
}

src_configure() {
	econf \
		--with-libvuurmuur-includes=/usr/include \
		--with-libvuurmuur-libraries=/usr/lib \
		--with-plugindir=/usr/lib/vuurmuur \
		--with-shareddir=/usr/share/vuurmuur
		--with-localedir=/usr/share/locale \
		--with-widec=yes
}

src_compile() {
	emake || die "emake failed"
}

src_install() {
	einstall

	doinitd "${FILESDIR}"/vuurmuur.init vuurmuur

	diropts -m0700
	dodir /etc/vuurmuurauto
	dodir /etc/vuurmuur/plugins
	dodir /etc/vuurmuur/textdir/interface
	dodir /etc/vuurmuur/textdir/rules
	dodir /etc/vuurmuur/textdir/services

	insinto /etc/vuurmuur
	newins skel/etc/vuurmuur/config.conf.sample config.conf

	insinto /etc/vuurmuur/plugins
	doins plugins/textdir/textdir.conf

	cd ..   # TODO: why?

	insinto /etc/vuurmuur/textdir
	doins -r zones
	dodir /etc/vuurmuur/textdir/zones/dmz/networks
	dodir /etc/vuurmuur/textdir/zones/ext/networks/internet/hosts
	dodir /etc/vuurmuur/textdir/zones/ext/networks/internet/groups
	dodir /etc/vuurmuur/textdir/zones/lan/networks
	dodir /etc/vuurmuur/textdir/zones/vpn/networks

	if ( use logrotate ); then
		insopts -m0600
		insinto /etc/logrotate.d
		newins scripts/vuurmuur-logrotate vuurmuur
	fi
}

pkg_postinst() {
	elog "The vuurmuur daemon must run in order to use the vuurmuur_conf"
	elog "console tool. If this is a new install, start it with:"
	elog "/etc/init.d/vuurmuur start"
	elog
	elog "Execute the following command to start the vuurmuur daemon at"
	elog "boot time:"
	elog "rc-update add vuurmuur default"
}
