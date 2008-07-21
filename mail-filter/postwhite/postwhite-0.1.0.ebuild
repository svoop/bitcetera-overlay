# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

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
	dosbin postwhite
	"${S}"/postwhite --prefix "${D}" configure
	keepdir /etc/postfix/postwhite
}
