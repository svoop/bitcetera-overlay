# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6
inherit autotools readme.gentoo-r1 user

DESCRIPTION="A software motion detector"
HOMEPAGE="https://motion-project.github.io"
SRC_URI="https://github.com/Motion-Project/motion/archive/release-4.0.1.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~ppc ~ppc64 ~sparc ~x86"
IUSE="ffmpeg libav mmal mysql postgres v4l"

RDEPEND="
	ffmpeg? (
		libav? ( media-video/libav:= )
		!libav? ( media-video/ffmpeg:0= )
	)
	virtual/jpeg
	mmal? ( media-libs/raspberrypi-userland )
	mysql? ( virtual/mysql )
	postgres? ( dev-db/postgresql )
"
DEPEND="${RDEPEND}
	v4l? ( virtual/os-headers media-libs/libv4l )
"

DISABLE_AUTOFORMATTING="yes"
DOC_CONTENTS="You need to setup /etc/motion/motion.conf before running
motion for the first time.
You can install motion detection as a service, use:
rc-update add motion default
"

pkg_setup() {
	enewuser motion -1 -1 -1 video
}

S="${WORKDIR}"/${PN}-release-${PV}
src_prepare() {
	eapply_user

	eautoreconf
}

src_configure() {
	econf \
		$(use_with ffmpeg) \
		$(use_with mmal) \
		$(use_with mysql) \
		$(use_with postgres pgsql) \
		$(use_with v4l) \
		--without-optimizecpu
}

src_install() {
	emake \
		DESTDIR="${D}" \
		docdir=/usr/share/doc/${PF} \
		examplesdir=/usr/share/doc/${PF}/examples \
		install

	newinitd "${D}"/usr/share/doc/${PF}/examples/motion.init-Debian motion

	mv -vf "${D}"/etc/motion/motion{-dist,}.conf || die

	readme.gentoo_create_doc
}
