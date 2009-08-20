# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-admin/eselect-ruby/eselect-ruby-20081227.ebuild,v 1.13 2009/05/15 14:27:27 aballier Exp $

DESCRIPTION="Manages multiple Ruby versions"
HOMEPAGE="http://www.gentoo.org"
SRC_URI="http://www.funtoo.org/distfiles/ruby.eselect-${PVR}.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="alpha amd64 arm hppa ia64 ~mips ppc ppc64 s390 sh sparc x86 ~sparc-fbsd ~x86-fbsd"
IUSE="format-executable"

RDEPEND=">=app-admin/eselect-1.0.2"

src_unpack() {
	unpack ${A}
	if use format-executable ; then
		epatch "${FILESDIR}/${PV}-format-executable.patch"
		ewarn "Make sure ${EPREFIX}/etc/gemrc (YAML) contains the following:"
		ewarn "gem: --format-executable"
		epause 5
	fi
}

src_install() {
	insinto /usr/share/eselect/modules
	newins "${WORKDIR}/ruby.eselect-${PVR}" ruby.eselect || die
}
