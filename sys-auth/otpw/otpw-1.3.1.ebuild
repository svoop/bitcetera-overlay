# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit eutils

DESCRIPTION="OTPW is a one-time password list generator and verifier including a wrapper suitable for PAM."
HOMEPAGE="http://www.cl.cam.ac.uk/~mgk25/otpw.html"
SRC_URI="http://www.cl.cam.ac.uk/~mgk25/download/otpw-snapshot.tar.gz"   # TODO: sould be: download/{P}.tar.gz

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64"
IUSE="pam pic"

RDEPEND="pam? ( sys-libs/pam )"

DEPEND="${RDEPEND}"

src_compile() {
	sed -i "s/CC\s*=.*/CC = $(tc-getCC)/" "${S}"/Makefile
	sed -i "s/CFLAGS\s*=.*/CFLAGS = ${CFLAGS} \$(DFLAGS)/" "${S}"/Makefile
	emake || die "make failed"
}

src_install() {
	die "bad idea"
}