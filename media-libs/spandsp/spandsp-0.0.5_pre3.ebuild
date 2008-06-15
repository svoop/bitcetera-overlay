# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

DESCRIPTION="SpanDSP is a library of DSP functions for telephony."
HOMEPAGE="http://www.soft-switch.org/"

SRC_URI="http://www.soft-switch.org/downloads/spandsp/${P/_/}.tgz"
S="${WORKDIR}/${PN}-${PV%_pre*}"

SLOT="0"
LICENSE="GPL-2"
KEYWORDS="~amd64 ~ppc ~x86"

IUSE="doc sse mmx test"

DEPEND=">=media-libs/audiofile-0.2.6-r1
	>=media-libs/tiff-3.5.7-r1
	doc? ( app-doc/doxygen )"

RDEPEND="${DEPEND}"

src_compile() {
	econf \
		$(use_enable doc) \
		$(use_enable sse) \
		$(use_enable mmx) \
		|| die "econf failed"

	emake || die "emake failed"
}

src_install() {
	emake install DESTDIR="${D}" || die "make failed"

	dodoc AUTHORS COPYING INSTALL NEWS README
	use doc && dohtml -r doc/api
}
