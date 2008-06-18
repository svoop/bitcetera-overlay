# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit eutils pam

DESCRIPTION="OTPW is a one-time password list generator and verifier including a wrapper suitable for PAM."
HOMEPAGE="http://www.cl.cam.ac.uk/~mgk25/otpw.html"
SRC_URI="http://www.cl.cam.ac.uk/~mgk25/download/otpw-snapshot.tar.gz"   # TODO: sould be: download/{P}.tar.gz

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64"
IUSE="pam"

RDEPEND="pam? ( sys-libs/pam )"

DEPEND="${RDEPEND}"

S=${WORKDIR}/${PN}

src_compile() {
	sed -i "s/CC\s*=.*/CC = $(tc-getCC)/" "${S}"/Makefile
	sed -i "s/CFLAGS\s*=.*/CFLAGS = -fPIC ${CFLAGS} \$(DFLAGS)/" "${S}"/Makefile   # TODO: -fPIC should become obsolete in the next version
	emake otpw-gen || die "emake otpw-gen failed"
	emake demologin || die "emake demologin failed"
        if use pam; then
		emake pam_otpw.so || die "emake pam_otpw.so failed"
	fi
}

src_install() {
	mv "${S}"/demologin "${S}"/otpw-demologin
	dobin otpw-gen || "installing otpw-gen failed"
	dobin otpw-demologin || "installing otpw-demologin failed"
	if use pam; then
		dopammod pam_otpw.so || "installing pam_otpw.so failed"
	fi
	doman otpw-gen.1
	doman pam_otpw.8
}
