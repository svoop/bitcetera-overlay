# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-misc/dahdi-tools/dahdi-tools-2.1.0.2.ebuild,v 1.1 2009/03/10 17:08:00 chainsaw Exp $

inherit eutils

SRC_P="${P/_/-}"

DESCRIPTION="Userspace tools to configure the kernel modules from net-misc/dahdi"
HOMEPAGE="http://www.asterisk.org"
SRC_URI="http://downloads.digium.com/pub/telephony/dahdi-tools/releases/${SRC_P}.tar.gz"

LICENSE="GPL-2 LGPL-2.1"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND="net-misc/dahdi
	dev-libs/libusb"

RDEPEND="${DEPEND}"

src_unpack() {
	unpack ${A}

	# Rename the work directory if necessary
	if [[ "${SRC_P}" != "${P}" ]]; then
		mv "${SRC_P}" "${P}"
	fi
}

src_install() {
	emake DESTDIR="${D}" install || die "failed to install package"
	emake DESTDIR="${D}" config || die "failed to install package"

	# install init script
	newinitd "${FILESDIR}"/dahdi.init dahdi
}
