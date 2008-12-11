# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

DESCRIPTION="The userspace tools to configure the kernel modules for the package net-misc/dahdi"
HOMEPAGE="http://www.asterisk.org"
SRC_URI="http://downloads.digium.com/pub/telephony/dahdi-tools/releases/${P}.tar.gz"

LICENSE="GPL-2 LGPL-2.1"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND="net-misc/dahdi
	dev-libs/libusb"

RDEPEND="${DEPEND}"

src_install() {
	emake DESTDIR="${D}" install || die "failed to install package"
	emake DESTDIR="${D}" config || die "failed to install package"

	# install init script
	newinitd "${FILESDIR}"/dahdi.initd dahdi
}
