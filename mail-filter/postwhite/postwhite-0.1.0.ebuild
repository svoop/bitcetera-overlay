# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit eutils

DESCRIPTION="Easy to use whitelist service for Postfix."
HOMEPAGE="http://www.bitcetera.com/en/products/postwhite"
SRC_URI="http://www.bitcetera.com/download/${P}.tgz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

RDEPEND="mail-mta/postfix
	>=dev-lang/ruby-1.8.6
	dev-ruby/facets
	dev-ruby/trollop"

DEPEND="${RDEPEND}"

src_install() {
	dosbin ${PN} || die "installing binary failed"
	newinitd "${FILESDIR}"/${PVR}/${PN}.init ${PN}
	newconfd "${FILESDIR}"/${PVR}/${PN}.conf ${PN}
	"${S}"/${PN} --prefix "${D}" configure
	fowners ${PN}:${PN} /etc/postfix/${PN}
	fperms 0770 /etc/postfix/${PN}
	fowners ${PN}:${PN} /var/spool/postfix/${PN}
	fperms 0770 /var/spool/postfix/${PN}
	keepdir /etc/postfix/postwhite
}

pkg_preinst() {
	enewgroup ${PN}
	enewuser ${PN} -1 -1 /dev/null ${PN}
}

pkg_postinst() {
	elog
	elog "The following steps are necessary to hook Postwhite into the Postfix"
	elog "workflow:"
	elog
	elog "1) List all email addresses that should be protected by Postwhite in"
	elog "   /etc/postfix/postwhite/recipients.yml."
	elog "2) Start the Postwhite daemon:"
	elog "   /etc/init.d/postwhite start"
	elog "3) Add the line 'check_policy_service inet:127.0.0.1:10035,' to the"
	elog "   'smtpd_recipient_restrictions' block which you find somewhere in"
	elog "   /etc/postfix/main.cf. You should place it near the end of the block"
	elog "   after all basic services (like 'reject_unauth_destination,') and"
	elog "   the greylist service (like Postgrey) but before the anti-SPAM services"
	elog "   (like DSPAM or SpamAssassin) in order to prevent unnecessary workload."
	elog "4) Reload Postfix to bring your changes into effect:"
	elog "   /etc/init.d/postfix reload"
	elog
	elog "Execute the following command if you wish to start the Postwhite daemon"
	elog "at boot time:"
	elog
	elog "rc-update add postwhite default"
	elog
	epause 5
}
