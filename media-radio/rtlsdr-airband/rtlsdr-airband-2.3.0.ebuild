# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

MY_P="RTLSDR-Airband-${PV}"

DESCRIPTION="RTLSDR AM demodulator with support for multiple channels per dongle"
HOMEPAGE="https://github.com/szpajder/RTLSDR-Airband"
SRC_URI="https://github.com/szpajder/RTLSDR-Airband/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~x86 ~arm"
IUSE="nfm fftw"

DEPEND="
	dev-libs/libconfig
"
RDEPEND="${DEPEND}
  net-wireless/rtl-sdr
	media-libs/libogg
	media-libs/libvorbis
	media-libs/libshout
	media-sound/lame
	fftw? ( sci-libs/fftw )
"

S="${WORKDIR}/${MY_P}"

src_compile() {
	if use nfm; then
		nfm="1"
	else
		nfm="0"
	fi
	case `uname -m` in
	x86*)
		platform="x86"
		;;
	armv7*)
		platform="armv7-generic"
		;;
	armv8*)
		platform="armv8-generic"
		;;
	*)
		die "unsupported platform"
		;;
	esac

	emake PLATFORM="${platform}" NFM="${nfm}" || die "compiling rtlsdr-airband for ${platform} failed"
}

src_install() {
	exeinto /usr/bin
	newexe rtl_airband rtlsdr-airband || die "installing rtlsdr-airband failed"

	newinitd "${FILESDIR}"/rtlsdr-airband.init rtlsdr-airband || die "installing init failed"
	newconfd "${FILESDIR}"/rtlsdr-airband.conf rtlsdr-airband || die "installing conf failed"

	insopts -m0640
	insinto /etc/rtlsdr-airband
	doins config/* || die "installing sample config failed"
}


pkg_postinst() {
	elog "If this is a new install, take a look at the sample configuration"
	elog "files in /etc/rtlsdr-airband, copy or symlink the best fit to"
	elog "/etc/rtlsdr-airband/rtlsdr-airband.conf and modify it to your liking."
}
