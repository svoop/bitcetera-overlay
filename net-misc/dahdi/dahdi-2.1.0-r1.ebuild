# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit linux-mod eutils flag-o-matic

MY_P="${P/dahdi/dahdi-linux}"

DESCRIPTION="This package contains the kernel modules for DAHDI."
HOMEPAGE="http://www.asterisk.org"
SRC_URI="http://downloads.digium.com/pub/telephony/dahdi-linux/releases/${MY_P}.tar.gz
http://downloads.digium.com/pub/telephony/firmware/releases/dahdi-fw-oct6114-064-1.05.01.tar.gz
http://downloads.digium.com/pub/telephony/firmware/releases/dahdi-fw-oct6114-128-1.05.01.tar.gz
http://downloads.digium.com/pub/telephony/firmware/releases/dahdi-fw-tc400m-MR6.12.tar.gz
http://downloads.digium.com/pub/telephony/firmware/releases/dahdi-fw-vpmadt032-1.07.tar.gz"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="echpec"

DEPEND=""
RDEPEND="${DEPEND}"

QA_EXECSTACK="opt/bin/zaphpec_register opt/bin/zaphpec_enable"

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
	die "HPEC is not available for your architecture, please remove the 'echpec' USE flag and retry."
}

src_unpack() {
	unpack ${A}
	# copy the firmware files to the correct location
	#
	for file in ${A} ; do
		cp "${DISTDIR}"/${file} "${MY_P}"/drivers/dahdi/firmware/
	done
	cp *bin "${MY_P}"/drivers/dahdi/firmware/

	cd "${MY_P}"
	epatch "${FILESDIR}"/${P}-install.patch

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
	cd "${MY_P}"
	unset ARCH
	emake KSRC="${KERNEL_DIR}" DESTDIR="${D}" modules || die "failed to build module"

	# download hpec utils
	if use echpec; then
		cd "${S}"
		wget -O zaphpec_register "http://downloads.digium.com/pub/register/x86-${HPEC_ARCH}/register"
		wget -O zaphpec_enable "http://downloads.digium.com/pub/telephony/hpec/${HPEC_ARCH}-bit/zaphpec_enable"
	fi
}

src_install() {
	cd "${MY_P}"

	# setup directory structure so udev rules get installed
	#
	mkdir -p "${D}"/etc/udev/rules.d

	einfo "Installing kernel module"
	emake KSRC="${KERNEL_DIR}" DESTDIR="${D}" install || die "failed to install module"
	rm -rf "$D"/lib/modules/*/modules.*
}

src_postinst() {
	# instructions for hpec
	if use echpec; then
		elog "HPEC is a commercial echo canceller. If you have purchased telephony"
		elog "hardware from Digium, you might be eligible for a free HPEC license:"
		elog "http://www.digium.com/en/products/software/hpec.php"
		elog ""
		elog "HPEC has to be registered once with 'zaphpec_register' and then enabled"
		elog "with 'zaphpec_enable' every time the Zaptel drivers are loaded. The Zaptel"
		elog "init script does so implicitly."
	fi
}