# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

DESCRIPTION="Vale is a library for streaming media."
HOMEPAGE="http://www.soft-switch.org/"
SRC_URI="http://www.soft-switch.org/downloads/vale/${P}.tgz"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="doc mmx sse"

RDEPEND=""
DEPEND="${RDEPEND}
	doc? ( app-doc/doxygen
		dev-libs/libxslt )"

S=${WORKDIR}/${PN}-$(get_version_component_range 1-3)

#src_unpack() {
#
#}

#src_compile() {
#	econf --disable-dependency-tracking \
#		$(use_enable doc) \
#		$(use_enable mmx) \
#		$(use_enable sse)
##		$(use_enable test tests) \
##		$(use_enable test test-data)
#	emake || die "emake failed."
#}

src_install () {
	emake DESTDIR="${D}" install || die	"emake install failed."
	dodoc AUTHORS NEWS README
	use doc && dohtml -r doc/{api/html/*,t38_manual}
}
