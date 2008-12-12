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
IUSE=""

DEPEND=""
RDEPEND=""

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
}

src_compile() {
	cd "${MY_P}"
	unset ARCH
	emake KSRC="${KERNEL_DIR}" DESTDIR="${D}" modules || die "failed to build module"
}

src_install() {
	cd "${MY_P}"

	# setup directory structure so udev rules get installed
	mkdir -p "${D}"/etc/udev/rules.d

	# fix udev rules to work with both asterisk and callweaver
	sed -i 's/GROUP="asterisk"/GROUP="dialout"/' etc/udev/rules.d/dahdi.rules

	einfo "Installing kernel module"
	emake KSRC="${KERNEL_DIR}" DESTDIR="${D}" install || die "failed to install module"
	rm -rf "$D"/lib/modules/*/modules.*
}
