# Copyright 1999-2004 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit toolchain-funcs

DESCRIPTION="IR senders and receivers from IRTrans (www.irtrans.com) need this software instead of the LIRC daemon."
HOMEPAGE="http://www.irtrans.com"
SRC_URI="http://www.irtrans.de/download/Server/Linux/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64 ~x86"
IUSE="ccf"

DEPEND="virtual/libc"

pkg_setup() {
	eval unset ${!LC_*} LANG
}

src_unpack() {
	unpack ${A}
	sed -i "s/CC\s*=.*/CC = $(tc-getCC)/" ${S}/makefile
	sed -i "s/CFLAGS\s*=.*/CFLAGS = ${CFLAGS}/" ${S}/makefile
}

src_compile() {
    if use ccf ; then
		emake irserver || die
	else
		emake irserver_noccf || die
	fi
	emake irclient || die
}

src_install() {
	dobin irserver
	dobin irclient
	newinitd ${FILESDIR}/init.d/irserver irserver
	newconfd ${FILESDIR}/conf.d/irserver irserver
	dodir /etc/irserver/remotes
}

pkg_postinst() {
	einfo
	einfo "Perform the following steps to complete the installation:"
	einfo
	einfo "1) Use the the following command to run the server in the foreground and"
	einfo "   check if you get IR codes when firing with your remote control on the"
	einfo "   IRTrans device:"
	einfo "   irserver -debug_code /dev/ttyUSB0" 
	einfo
	einfo "2) While still running the above server, use the following command to"
	einfo "   learn IR codes and create a myremote.rem file which you should put"
	einfo "   into /etc/irserver/remotes:"
	einfo "   irclient localhost"
	einfo
	einfo "3) Start the irserver with the following command:"
	einfo "   /etc/init.d/irserver start"
	einfo
	einfo "4) Use the following command to have the daemon start on future boots:"
	einfo "   rc-update add irserver default"
	einfo
	einfo "You can execute shell commands at the touch of a remote control button."
	einfo "Just emerge app-misc/lirc and create an /etc/lircrc according to the"
	einfo "documentation on http://www.lirc.org/html/configure.html#lircrc_format"
	einfo "The irexec daemon is started along with irserver if it is installed and"
	einfo "/etc/lircrc exists."
	ewarn
	ewarn "Do never run lircd/lircmd and irserver simultanously! It won't work!"
	ewarn
}
