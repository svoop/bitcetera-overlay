# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit toolchain-funcs eutils linux-mod

## NOTE:
#
# bri and florz disabled
#

#BRI_VERSION="0.3.0-PRE-1v"
#FLORZ_VERSION="0.3.0-PRE-1o_florz-12"
HPEC_VERSION="9.00.007"

#IUSE="bri ecmark ecmark2 ecmark3 ecaggressive eckb1 ecmg2 ecsteve ecsteve2 florz rtc ukcid watchdog zapras zapnet"
IUSE="echpec ecmark ecmark2 ecmark3 ecaggressive eckb1 ecmg2 ecsteve ecsteve2 rtc ukcid usb watchdog wanpipe zapras zapnet"

MY_P="${P/_/-}"

DESCRIPTION="Drivers for Digium and ZapataTelephony cards"
HOMEPAGE="http://www.asterisk.org"
SRC_URI="http://ftp.digium.com/pub/zaptel/releases/${MY_P}.tar.gz"
#	 bri? ( http://www.junghanns.net/downloads/bristuff-${BRI_VERSION}.tar.gz )
#	 florz? ( http://www.netdomination.org/pub/asterisk/zaphfc_${FLORZ_VERSION}.diff.gz )"

S="${WORKDIR}/${MY_P}"

S_BRI="${WORKDIR}/bristuff-${BRI_VERSION}"

SLOT="0"
LICENSE="GPL-2"
KEYWORDS=""


RDEPEND="virtual/libc
	usb? ( dev-libs/libusb )
	>=dev-libs/newt-0.50.0"

DEPEND="${RDEPEND}
	virtual/linux-sources"

RESTRICT="strip"
QA_EXECSTACK="opt/bin/zaphpec_register opt/bin/zaphpec_enable"

# list of echo canceller use flags,
# first active in this list is selected (=order does matter)
ZAP_EC_FLAGS="ecmark ecmark2 ecmark3 ecsteve ecsteve2 eckb1 ecmg2"

### Begin: Helper functions

select_echo_cancel() {
	local myEC=""

	for x in ${ZAP_EC_FLAGS}; do
		if use $x; then
			myEC=$(echo "$x" | sed -e "s:^ec::" | tr '[:lower:]' '[:upper:]')
			break;
		fi
	done

	echo ${myEC}
}

zconfig_disable() {
	if grep -q "${1}" "${S}"/kernel/zconfig.h; then
		# match a little more than ${1} so we can use zconfig_disable
		# to disable all echo cancellers in zconfig.h w/o calling it several times
		sed -i -e "s:^[ \t]*#define[ \t]\+\(${1}[a-zA-Z0-9_-]*\).*:#undef \1:" \
			"${S}"/kernel/zconfig.h
	fi

	return $?
}

zconfig_enable() {
	if grep -q "${1}" "${S}"/kernel/zconfig.h; then
		sed -i  -e "s:^/\*[ \t]*#define[ \t]\+\(${1}\).*:#define \1:" \
			-e "s:^[ \t]*#undef[ \t]\+\(${1}\).*:#define \1:" \
			"${S}"/kernel/zconfig.h
	fi

	return $?
}

hpec_detect() {
	if [ "$(tc-arch)" == "x86" ]; then
		HPEC_ARCH="32"
		HPEC_CPU="i386"
		return
	fi	
	if [ "$(tc-arch)" == "amd64" ]; then
		HPEC_ARCH="64"
		HPEC_CPU="opteron"
		if grep -q "GenuineIntel" /proc/cpuinfo; then HPEC_CPU="nocona"; fi
		return
	fi
	die "HPEC is not available for your architecture, please remove the 'echpec' flag and retry."
}

### End: Helper functions

pkg_setup() {
	ewarn "For version 2 and later you have to emerge dahdi instead of zaptel:"
	ewarn "http://blogs.digium.com/2008/05/19"
	epause 5
	
	local result=0 numec=0

	linux-mod_pkg_setup

	elog "Running pre-flight checks..."

	# basic zaptel checks
	if kernel_is 2 4 ; then
		if ! linux_chkconfig_present CRC32; then
			echo
			eerror "Your kernel lacks CRC32 support!"
			eerror "Enable CONFIG_CRC32!"
			result=$((result+1))
		fi
	else
		if ! linux_chkconfig_present CRC_CCITT; then
			echo
			eerror "Your kernel lacks CRC_CCIT support!"
			eerror "Enable CONFIG_CRC_CCIT!"
			result=$((result+1))
		fi
	fi

	# check if multiple echo cancellers have been selected
	for x in ${ZAP_EC_FLAGS}; do
		use $x && numec=$((numec+1))
	done
	if [[ $numec -gt 1 ]]; then
		# multiple flags are active, only the first in the ZAP_EC_FLAGS list
		# will be used, make sure the user knows about this
		echo
		ewarn "Multiple echo canceller flags are active but only one will be used!"
		ewarn "Selected: $(select_echo_cancel)"
	fi

	# we need at least HDLC generic support
	if use zapnet && ! linux_chkconfig_present HDLC; then
		echo
		eerror "zapnet: Your kernel lacks HDLC support!"
		eerror "zapnet: Enable CONFIG_HDLC* to use zaptel network support!"
		result=$((result+1))
	fi

	# zapras needs PPP support
	if use zapras && ! linux_chkconfig_present PPP; then
		echo
		eerror "zapras: Your kernel lacks PPP support!"
		eerror "zapras: Enable CONFIG_PPP* to use zaptel ras support!"
		result=$((result+1))
	fi

	# rtc needs linux-2.6 and CONFIG_RTC
	if use rtc; then
		if ! kernel_is 2 6; then
			echo
			eerror "rtc: >=Linux-2.6.0 is needed for rtc support!"
			result=$((result+1))
		fi

		if ! linux_chkconfig_present RTC; then
			eerror "rtc: Your kernel lacks RealTime-Clock support!"
			result=$((result+1))
		fi
	fi

	if [[ $result -gt 0 ]]; then
		echo
		ewarn "One or more of the neccessary precondition(s) is/are not met!"
		ewarn "Look at the messages above, resolve the problem (or disable the use-flag) and try again"
		echo

		if [[ $result -lt 3 ]]; then
			eerror "[$result Error(s)] Zaptel is not happy :("
		else
			eerror "[$result Error(s)] You're making zaptel cry :'("
		fi
		die "[$result] Precondition(s) not met"
	fi

	echo
	elog "Zaptel is happy and continues... :)"
}

src_unpack() {
	unpack ${A}

	cd "${S}"
	epatch "${FILESDIR}"/${P}-gentoo.diff
#	epatch "${FILESDIR}"/zaptel-1.2.9.1-gcc411_is_a_retard-kbuild.patch

	use ukcid && \
		epatch ${FILESDIR}/${PN}-1.2.0-ukcid.patch

	use wanpipe && \
		epatch ${FILESDIR}/${PN}-wanpipe_hdlc.patch

	# try to apply bristuff patch
#	if use bri; then
#		# fix for userpriv
#		chmod -R a=rwX "${S_BRI}"
#
#		elog "Patching zaptel w/ BRI stuff (${BRI_VERSION})"
#		epatch "${S_BRI}"/patches/zaptel.patch
#
#		cd "${S_BRI}"
#
#		if use florz; then
#			elog "Using florz patches (${FLORZ_VERSION}) for zaphfc"
#
#			# remove as soon as there's a new florz patch available
#			sed -i -e "s:zaptel-1\.2\.5:zaptel-1.2.6:g" \
#				"${WORKDIR}"/zaphfc_${FLORZ_VERSION}.diff
#
#			epatch "${WORKDIR}"/zaphfc_${FLORZ_VERSION}.diff
#		fi
#
#		# patch includes
#		sed -i  -e "s:^#include.*zaptel\.h.*:#include <zaptel.h>:" \
#			qozap/qozap.c \
#			zaphfc/zaphfc.c \
#			cwain/cwain.c
#
#		# patch makefiles
#		sed -i  -e "s:^ZAP[\t ]*=.*:ZAP=-I${S}:" \
#			-e "s:^MODCONF=.*:MODCONF=/etc/modules.d/zaptel:" \
#			-e "s:linux-2.6:linux:g" \
#			qozap/Makefile \
#			zaphfc/Makefile \
#			cwain/Makefile
#
#		sed -i  -e "s:^\(CFLAGS+=-I. \).*:\1 \$(ZAP):" \
#			zaphfc/Makefile
#
#		cd "${S}"
#	fi

### Configuration changes
	local myEC

	# prepare zconfig.h
	myEC=$(select_echo_cancel)
	if [[ -n "${myEC}" ]]; then
		elog "Selected echo canceller: ${myEC}"
		# disable default first, set new selected ec afterwards
		zconfig_disable ECHO_CAN
		zconfig_enable ECHO_CAN_${myEC}
	fi

	# enable rtc support on 2.6
	if use rtc && linux_chkconfig_present RTC && kernel_is 2 6; then
		elog "Enabling ztdummy RTC support"
		zconfig_enable USE_RTC
	fi

	# enable agressive echo surpression
	use ecaggressive && \
		zconfig_enable AGGRESSIVE_SUPPRESSOR

	# ppp ras support
	use zapras && \
		zconfig_enable CONFIG_ZAPATA_PPP

	# frame relay, syncppp...
	use zapnet && \
		zconfig_enable CONFIG_ZAPATA_NET

	# zaptel watchdog
	use watchdog && \
		zconfig_enable CONFIG_ZAPTEL_WATCHDOG

	# prepare hpec
	if use echpec; then
		elog "Support for commercial HPEC echo canceller."
		hpec_detect
		cd "${S}"/kernel/hpec
		wget -O hpec.tgz \
			"http://downloads.digium.com/pub/telephony/hpec/${HPEC_ARCH}-bit/hpec-${HPEC_VERSION}-${HPEC_CPU}.tar.gz" \
			|| die "HPEC download failed"
		tar xzf hpec.tgz
	fi
}

src_compile() {
	# fun, zaptel uses autotools now
	econf \
		--sysconfdir=/etc \
		$(use_with usb) || die

	# build
	make KVERS=${KV_FULL} \
	     KSRC=${KV_DIR} ARCH=$(tc-arch-kernel) || die "make failed"

	cd "${S}"/kernel/xpp/utils
	make || die "make xpp utils failed"

#	if use bri; then
#		cd "${S_BRI}"
#		for x in cwain qozap zaphfc; do
#			elog "Building ${x}..."
#			make KVERS=${KV_FULL} \
#				KSRC=/usr/src/linux \
#				ARCH=$(tc-arch-kernel) \
#				-C ${x} || die "make ${x} failed"
#		done
#	fi

	# download hpec utils
	if use echpec; then
		cd "${S}"
		wget -O zaphpec_register "http://downloads.digium.com/pub/register/x86-${HPEC_ARCH}/register"
		wget -O zaphpec_enable "http://downloads.digium.com/pub/telephony/hpec/${HPEC_ARCH}-bit/zaphpec_enable"
	fi
}

src_install() {
	kernel_is 2 4 && cp /etc/modules.conf "${D}"/etc
	make DESTDIR="${D}" ARCH=$(tc-arch-kernel) \
	     KVERS=${KV_FULL} KSRC=/usr/src/linux install || die

	dodoc ChangeLog README README.Linux26 README.fxsusb zaptel.init
	dodoc zaptel.conf.sample LICENSE zaptel.sysconfig README.fxotune

	# additional tools
	dobin ztmonitor ztspeed zttest fxotune

	# install all header files, several packages need the complete set
	# (e.g. sangoma wanpipe)
	insinto /usr/include/zaptel
	doins *.h

#	if use bri; then
#		elog "Installing bri"
#		cd "${S_BRI}"
#
#		insinto /lib/modules/${KV_FULL}/misc
#		doins qozap/qozap.${KV_OBJ}
#		doins zaphfc/zaphfc.${KV_OBJ}
#		doins cwain/cwain.${KV_OBJ}
#
#		# install example configs for octoBRI and quadBRI
#		insinto /etc
#		doins qozap/zaptel.conf.octoBRI
#		newins qozap/zaptel.conf zaptel.conf.quadBRI
#		newins zaphfc/zaptel.conf zaptel.conf.zaphfc
#
#		insinto /etc/asterisk
#		doins qozap/zapata.conf.octoBRI
#		newins qozap/zapata.conf zapata.conf.quadBRI
#		newins zaphfc/zapata.conf zapata.conf.zaphfc
#
#		docinto bristuff
#		dodoc CHANGES INSTALL
#
#		docinto bristuff/qozap
#		dodoc qozap/LICENSE qozap/TODO qozap/*.conf*
#
#		docinto bristuff/zaphfc
#		dodoc zaphfc/LICENSE zaphfc/*.conf
#
#		docinto bristuff/cwain
#		dodoc cwain/TODO cwain/LICENSE
#
#		cd "${S}"
#	fi

	# install init script
	newinitd "${FILESDIR}"/zaptel.rc6 zaptel
	newconfd "${FILESDIR}"/zaptel.confd zaptel

	# install devfsd rule file
	insinto /etc/devfs.d
	newins "${FILESDIR}"/zaptel.devfsd zaptel

#	# install udev rule file
#	insinto /etc/udev/rules.d
#	newins "${FILESDIR}"/zaptel.udevd 10-zaptel.rules

	# fix permissions if there's no udev / devfs around
	if [[ -d "${D}"/dev/zap ]]; then
		chown -R root:dialout	"${D}"/dev/zap
		chmod -R u=rwX,g=rwX,o= "${D}"/dev/zap
	fi

	# install xpp utils
	cd "${S}"/kernel/xpp/utils
	make DESTDIR="${D}" install || die "failed xpp utils install"

	# install hpec utils
	if use echpec; then
		cd "${S}"
		diropts -o root -g root -m 0744
		dodir /opt/bin
		insinto /opt/bin
		insopts -o root -g root -m 0700	
		doins zaphpec_register || die "installing zaphpec_register failed"
		doins zaphpec_enable || die "installing zaphpec_enable failed"
	fi
}

pkg_postinst() {
	linux-mod_pkg_postinst

	echo
	elog "Use the /etc/init.d/zaptel script to load zaptel.conf settings on startup!"
	echo

#	if use bri; then
#		elog "Bristuff configs have been merged as:"
#		elog ""
#		elog "${ROOT}etc/"
#		elog "    zaptel.conf.zaphfc"
#		elog "    zaptel.conf.quadBRI"
#		elog "    zaptel.conf.octoBRI"
#		elog ""
#		elog "${ROOT}etc/asterisk/"
#		elog "    zapata.conf.zaphfc"
#		elog "    zapata.conf.quadBRI"
#		elog "    zapata.conf.octoBRI"
#		echo
#	fi

	# fix permissions if there's no udev / devfs around
	if [[ -d "${ROOT}"dev/zap ]]; then
		chown -R root:dialout	"${ROOT}"dev/zap
		chmod -R u=rwX,g=rwX,o= "${ROOT}"dev/zap
	fi

	# instructions for HPEC
	if use echpec; then
		elog "HPEC is a commercial echo canceller. If you have purchased telephony"
		elog "hardware from Digium, you might be eligible for a free HPEC license:"
		elog "http://www.digium.com/en/products/software/hpec.php"
		elog ""
		elog "HPEC has to be registered once with 'zaphpec_register' and then enabled"
		elog "with 'zaphpec_enable' every time the Zaptel drivers are loaded."
		elog ""
		elog "Add the following line to '/etc/conf.d/local.start' in order to enable"
		elog "HPEC at boot time:"
		elog "zaphpec_enable"
	fi
}
