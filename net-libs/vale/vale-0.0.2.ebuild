# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

DESCRIPTION="Vale is a library for streaming media."
HOMEPAGE="http://www.soft-switch.org/"
SRC_URI="http://www.soft-switch.org/downloads/vale/${P}.tgz"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="mmx sse"

RDEPEND=""
DEPEND=""

src_unpack() {
	unpack ${A}
	
	# Workaround for vale-0.0.2.tgz expanding to vale-0.0.1 
	if [[ ! -d ${P} ]]; then
		mv vale-0.0.1 ${P}
	fi
}

src_compile() {
	econf --disable-dependency-tracking \
		$(use_enable mmx) \
		$(use_enable sse)
	emake || die "emake failed"
}

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed"
	dodoc AUTHORS NEWS README
}
