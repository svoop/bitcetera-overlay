# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=5

inherit linux-info

MY_PV=03ca8d60df7afc07db5adb91ec2457c23f4d9d59
DESCRIPTION="Simple command-line webcam application"
HOMEPAGE="https://github.com/fsphil/fswebcam"
SRC_URI="https://github.com/fsphil/${PN}/archive/${MY_PV}.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND="media-libs/gd[jpeg,png,truetype]"
RDEPEND="${DEPEND}"

S="${WORKDIR}"/${PN}-${MY_PV}

pkg_setup() {
	if linux_config_exists ; then
		einfo "Checking kernel configuration at $(linux_config_path)..."
		if ! linux_chkconfig_present VIDEO_DEV ; then
			ewarn 'Kernel option VIDEO_DEV=[ym] needed but missing'
		fi
	fi
}

src_configure() {
	econf --enable-32bit-buffer
}
