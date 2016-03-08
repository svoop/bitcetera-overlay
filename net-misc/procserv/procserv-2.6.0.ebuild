# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

DESCRIPTION="Daemon wrapper which binds stdin, stdout and stderr to a TCP port"
HOMEPAGE="https://sourceforge.net/projects/procserv/"
SRC_URI="mirror://sourceforge/${PN}/procServ-${PV}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86 ~arm"

DEPEND="net-libs/libtelnet"

S="${WORKDIR}/procServ-${PV}"

src_install() {
  emake DESTDIR="${D}" install
  dosym procServ /usr/bin/procserv || die "dosym failed"
}
