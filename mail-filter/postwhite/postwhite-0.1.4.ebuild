# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="2"

inherit eutils

DESCRIPTION="Per-recipient whitelist policy server for Postfix MTA managed entirely by emails."
HOMEPAGE="http://www.bitcetera.com/products/postwhite"
SRC_URI="https://github.com/svoop/${PN}/archive/${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND="mail-mta/postfix
	>=dev-lang/ruby-1.8.7"
RDEPEND="${DEPEND}"

pkg_setup() {
	enewgroup ${PN}
	enewuser ${PN} -1 -1 /dev/null ${PN}
}

src_install() {
	dosbin ${PN} || die "installing binary failed"
	newinitd "${FILESDIR}"/${PVR}/${PN}.init ${PN}
	newconfd "${FILESDIR}"/${PVR}/${PN}.conf ${PN}
	"${S}"/${PN} --prefix "${D}" configure
	keepdir /etc/postfix/postwhite
}

pkg_postinst() {
	elog
	elog "The Ruby gems necessary for Postwhite to work are no longer a dependency"
	elog "since maintenance on Gentoo is rather poor. Make sure you have installed"
	elog "the following gems manually:"
	elog
	elog "* trollop"
	elog "* facets"
	elog
	elog "The following steps are necessary to hook Postwhite into the Postfix"
	elog "workflow:"
	elog
	elog "1) List all email addresses that should be protected by Postwhite in:"
	elog "   /etc/postfix/postwhite/recipients.yml"
	elog "2) Start the Postwhite daemon:"
	elog "   /etc/init.d/postwhite start"
	elog "3) Add the line 'check_policy_service inet:127.0.0.1:10035,' to the"
	elog "   'smtpd_recipient_restrictions' block which you find somewhere in"
	elog "   /etc/postfix/main.cf. You should place it near the end of the block"
	elog "   after all basic services and the greylist service, but before the"
	elog "   anti-SPAM services such as DSPAM."
	elog "4) Reload Postfix to bring your changes into effect:"
	elog "   /etc/init.d/postfix reload"
	elog "5) Make the Postwhite daemon start at boot time:"
	elog "   rc-update add postwhite default"
	elog
	epause 5
}
