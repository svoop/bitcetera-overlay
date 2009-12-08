# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="2"

inherit autotools multilib

MY_PV=${PV/_beta/beta}
MY_P="Vuurmuur-${MY_PV}"

DESCRIPTION="Frontend for iptables featuring easy to use command line utils, rule- and logdaemons"
HOMEPAGE="http://www.vuurmuur.org"
SRC_URI="ftp://ftp.vuurmuur.org/releases/${MY_PV}/${MY_P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="logrotate"

RDEPEND="=net-libs/libvuurmuur-${PV}
	>=sys-libs/ncurses-5
	logrotate? ( app-admin/logrotate )"

S="${WORKDIR}/${MY_P}/${PN}-${MY_PV}"

src_unpack() {
	default
	cd ${MY_P}
	for component in vuurmuur vuurmuur_conf; do
		unpack "./${component}-${MY_PV}.tar.gz"   # upstream supplies tarball inside tarball
	done
}

src_configure() {
	econf \
		--with-libvuurmuur-includes=/usr/include \
		--with-libvuurmuur-libraries=/usr/$(get_libdir)
	cd "../vuurmuur_conf-${MY_PV}"
	econf \
		--with-libvuurmuur-includes=/usr/include \
		--with-libvuurmuur-libraries=/usr/$(get_libdir) \
		--with-localedir=/usr/share/locale \
		--with-widec=yes
}

src_compile() {
	default
	emake -C "../vuurmuur_conf-${MY_PV}" || die "compiling vuurmuur_conf failed"
}

src_install() {
	emake DESTDIR="${D}" install || die "installing vuurmuur failed"

	newinitd "${FILESDIR}"/vuurmuur.init vuurmuur || die "installing init failed"
	newconfd "${FILESDIR}"/vuurmuur.conf vuurmuur || die "installing conf failed"
	
	insopts -m0600
	insinto /etc/vuurmuur
	newins config/config.conf.sample config.conf || die "installing config.conf failed"
	insopts -m0644

	if use logrotate; then
		insinto /etc/logrotate.d
		newins scripts/vuurmuur-logrotate vuurmuur || die "installing logrotate config failed"
	fi

	cd "../vuurmuur_conf-${MY_PV}"

	emake DESTDIR="${D}" install || die "installing vuurmuur_conf failed"
	
	# needed until the wizard scripts are copied by make
	exeinto /usr/share/scripts
	doexe scripts/*.sh || die "installing vuurmuur scripts failed"
}

pkg_postinst() {
	einfo "Please read the manual on www.vuurmuur.org now - you have"
	einfo "been warned!"
	einfo
	einfo "If this is a new install, make sure you define some rules"
	einfo "BEFORE you start the daemon in order not to lock yourself"
	einfo "out. The necessary steps are:"
	einfo "1) vuurmuur_conf"
	einfo "2) /etc/init.d/vuurmuur start"	
	einfo "3) rc-update add vuurmuur default"
}
