# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit user

DESCRIPTION="OGN radio message to APRS relay"
HOMEPAGE="https://github.com/glidernet"
SRC_URI="
  amd64? ( http://download.glidernet.org/x64/rtlsdr-ogn-bin-x64-${PV}.tgz )
  x86?   ( http://download.glidernet.org/x86/rtlsdr-ogn-bin-x86-${PV}.tgz )
  arm?   ( http://download.glidernet.org/arm/rtlsdr-ogn-bin-ARM-${PV}.tgz )
"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86 ~arm"
IUSE=""


DEPEND="
	dev-libs/libconfig
"
RDEPEND="${DEPEND}
  net-misc/ntp
  net-misc/procserv
	net-wireless/rtl-sdr
	sci-libs/fftw
	media-libs/jpeg
"
# might depend on media-libs/libjpeg-turbo from version 0.2.9 onwards

S="${WORKDIR}/${P}"

pkg_setup() {
	enewgroup ogn
	enewuser ogn -1 -1 -1 "ogn,usb"
}

src_install() {
	exeinto /usr/bin
	doexe rtlsdr-ogn || die "installing rtlsdr-ogn failed"
	doexe ogn-rf || die "installing ogn-rf failed"
	doexe ogn-decode || die "installing ogn-decode failed"
	doexe gsm_scan || die "installing gsm_scan failed"

	newinitd "${FILESDIR}"/rtlsdr-ogn.init rtlsdr-ogn || die "installing init failed"
	newconfd "${FILESDIR}"/rtlsdr-ogn.conf rtlsdr-ogn || die "installing conf failed"

	insopts -m0644
	insinto /etc
	newins Template.conf rtlsdr-ogn.conf || die "installing sample rtlsdr-ogn.conf failed"
}

pkg_postinst() {
	elog "If this is a new install, take a look at the configuration file"
	elog "/etc/rtlsdr-ogn.conf and modify it to your liking."
}
