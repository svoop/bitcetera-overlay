# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit eutils toolchain-funcs

DESCRIPTION="Utility to control and program CM11A, CM17A and CM12U X10 interfaces."
HOMEPAGE="http://heyu.tanj.com"
LICENSE="GPL-2"

SRC_URI="http://heyu.tanj.com/download/${P}.tgz"
RESTRICT="mirror"

SLOT="0"
KEYWORDS="~amd64 ~ppc ~x86"

IUSE="cm17a dmx ext0 ore rfxm rfxs"

DEPEND="virtual/libc"

src_unpack() {
	unpack ${A}
	cp -r ${S} "${S}-original"
	cd ${S}
	sh ./Configure
}

src_compile() {
	X10CONFIG="${T}" heyu stop
	econf \
		`use_without cm17a nocm17a`		\
		`use_without dmx nodmx`			\
		`use_without ext0 noext0`		\
		`use_without ore noore`			\
		`use_without rfxm norfxm`		\
		`use_without rfxs norfxs`		\
		|| die "configure failed"
	sed -i "s/CC\s*=.*/CC = $(tc-getCC)/" ${S}/Makefile
	sed -i "s/CFLAGS\s*=.*/CFLAGS = ${CFLAGS} \$(DFLAGS)/" ${S}/Makefile
	emake || die "make failed"
}

src_install() {
	dobin heyu
	doman heyu.1 x10config.5 x10scripts.5 x10sched.5
	newinitd ${FILESDIR}/${PV}/heyu.init heyu
	diropts -o nobody -g nogroup -m 0777
	dodir /var/tmp/heyu
	diropts -o root -g root -m 0744
	dodir /etc/heyu
	insinto /etc/heyu
	insopts -o root -g root -m 0644
	doins x10.config.sample
	doins x10.sched.sample
}

pkg_postinst() {
	einfo
	einfo "Don't forget to tell heyu where to find your CM11 or CM17. Therefore"
	einfo "the file /etc/heyu/x10.conf must contain a line starting with 'TTY'"
	einfo "followed by the corresponding device such as:"
	einfo
	einfo "TTY /dev/ttyS0     <-- on first serial port"
	einfo "TTY /dev/ttyS1     <-- on second serial port"
	einfo "TTY /dev/ttyUSB0   <-- on USB port"
	einfo
	einfo "To use your device on a USB port, the corresponding USB serial converter"
	einfo "kernel module must be loaded. Older CM11 are usually delivered with a"
	einfo "a Prolific 2303 cable (kernel module: pl2303) while newer come with a"
	einfo "FTDI cable (kernel module: ftdi_sio)."
	einfo
	einfo "Execute the following command if you wish to start the HEYU daemon"
	einfo "at boot time:"
	einfo
	einfo "rc-update add heyu default"
	einfo
	epause 5
}

pkg_prerm() {
	killall heyu
}
