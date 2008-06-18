# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit toolchain-funcs

DESCRIPTION="IR senders and receivers from IRTrans (www.irtrans.com) need this software instead of the LIRC daemon."
HOMEPAGE="http://www.irtrans.com"
SRC_URI="http://www.bitcetera.com/assets/media/irserver/${P}.tar.gz"

# The upstream author prefers not to change his naming scheme in order to
# include the version number. A versionized copy is therefore hosted on
# the server of the ebuild maintainer.

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="ccf"

pkg_setup() {
	eval unset ${!LC_*} LANG
}

src_compile() {
	sed -i "s/CC\s*=.*/CC = $(tc-getCC)/" "${S}"/makefile
	sed -i "s/CFLAGS\s*=.*/CFLAGS = ${CFLAGS}/" "${S}"/makefile
	if use ccf; then
		emake irserver || die "emake irserver failed"
	else
		emake irserver_noccf || die "emake irserver_noccf failed"
	fi
	emake irclient || die "emake irclient failed"
}

src_install() {
	dobin irserver || die "installing irserver binary failed"
	dobin irclient || die "installing irclient binary failed"
	newinitd "${FILESDIR}"/${PVR}/irserver.init irserver
	newconfd "${FILESDIR}"/${PVR}/irserver.conf irserver
	dodir /etc/irserver/remotes
}

pkg_postinst() {
	elog "Perform the following steps to complete the installation:"
	elog
	elog "1) Use the the following command to run the server in the foreground and"
	elog "   check if you get IR codes when firing with your remote control on the"
	elog "   IRTrans device:"
	elog "   irserver -debug_code /dev/ttyUSB0" 
	elog
	elog "2) While still running the above server, use the following command to"
	elog "   learn IR codes and create a myremote.rem file which you should put"
	elog "   into /etc/irserver/remotes:"
	elog "   irclient localhost"
	elog
	elog "3) Start the irserver with the following command:"
	elog "   /etc/init.d/irserver start"
	elog
	elog "4) Use the following command to have the daemon start on future boots:"
	elog "   rc-update add irserver default"
	elog
	elog "You can execute shell commands at the touch of a remote control button."
	elog "Just emerge app-misc/lirc and create an /etc/lircrc according to the"
	elog "documentation on http://www.lirc.org/html/configure.html#lircrc_format"
	elog "The irexec daemon is started along with irserver if it is installed and"
	elog "/etc/lircrc exists."
	ewarn
	ewarn "Do never run lircd/lircmd and irserver simultanously, it won't work!"
	ewarn
}
