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

RDEPEND="=net-libs/libvuurmuur-${PV}
	>=sys-libs/ncurses-5
	logrotate? ( app-admin/logrotate )"

S="${WORKDIR}/${MY_PN}-${PV}"

src_unpack() {
	unpack ${A} || die "unpacking failed"
	cd "${S}"
	find . -name "*.tar.gz" -exec tar xzf {} \; || die "unpacking components failed"
}

src_prepare() {
	for component in vuurmuur vuurmuur_conf; do
		cd "${S}/${component}-${PV}"
		if ! [ -d m4 ]; then mkdir m4; fi   # workaround for upstream issue
		eautoreconf || die "eautoreconf ${component} failed"
	done
}

src_configure() {
	cd "${S}/vuurmuur-${PV}"
	econf \
		--with-libvuurmuur-includes=/usr/include \
		--with-libvuurmuur-libraries=/usr/lib \
		|| die "econf vuurmuur failed"
	
	cd "${S}/vuurmuur_conf-${PV}"
	econf \
		--with-libvuurmuur-includes=/usr/include \
		--with-libvuurmuur-libraries=/usr/lib \
		--with-localedir=/usr/share/locale \
		--with-widec=yes \
		|| die "econf ${component} failed"
}

src_compile() {
	for component in vuurmuur vuurmuur_conf; do
		cd "${S}/${component}-${PV}"
		emake || die "emake ${component} failed"
	done
}

src_install() {
	cd "${S}/vuurmuur-${PV}"
	einstall || die "einstall vuurmuur failed"

	newinitd "${FILESDIR}"/vuurmuur.init vuurmuur
	newconfd "${FILESDIR}"/vuurmuur.conf vuurmuur

	diropts -m0700
	dodir /etc/vuurmuurauto
	dodir /etc/vuurmuur/plugins
	dodir /etc/vuurmuur/textdir/interface
	dodir /etc/vuurmuur/textdir/rules
	dodir /etc/vuurmuur/textdir/services

	insinto /etc/vuurmuur
	newins skel/etc/vuurmuur/config.conf.sample config.conf

	if ( use logrotate ); then
		insopts -m0600
		insinto /etc/logrotate.d
		newins scripts/vuurmuur-logrotate vuurmuur
	fi

	cd "${S}/vuurmuur_conf-${PV}"
	einstall || die "einstall vuurmuur_conf failed"

	cd "${S}"
	insinto /etc/vuurmuur/textdir
	doins -r zones
	dodir /etc/vuurmuur/textdir/zones/dmz/networks
	dodir /etc/vuurmuur/textdir/zones/ext/networks/internet/hosts
	dodir /etc/vuurmuur/textdir/zones/ext/networks/internet/groups
	dodir /etc/vuurmuur/textdir/zones/lan/networks
	dodir /etc/vuurmuur/textdir/zones/vpn/networks
}

pkg_postinst() {
	elog "If this is a new install, define some rules with vuurmuur_conf,"
	elog "save them and then start the service with:"
	elog "/etc/init.d/iptables save"
	elog "/etc/init.d/vuurmuur start"
	elog
	elog "Run the following command to start the vuurmuur daemon at boot:"
	elog "rc-update add vuurmuur default"
}
