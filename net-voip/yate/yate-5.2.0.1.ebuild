# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-voip/yate/yate-4.3.0.1.ebuild,v 1.5 2013/07/23 14:10:55 kensington Exp $

EAPI=5

inherit autotools eutils multilib versionator

DESCRIPTION="Yet Another Telephony Engine"
HOMEPAGE="http://yate.null.ro/"
SRC_URI="http://yate.null.ro/tarballs/yate$(get_major_version)/$(replace_version_separator 4 - ${P}).tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="debug gsm speex h323 ilbc mysql postgres ssl zlib qt4 spandsp sctp zaptel"

RDEPEND="
	media-sound/sox
	gsm? ( media-sound/gsm )
	speex? ( media-libs/speex )
	h323? ( >=net-libs/openh323-1.15.3 dev-libs/pwlib )
	mysql? ( dev-db/mysql )
	postgres? ( dev-db/postgresql-base )
	ssl? ( dev-libs/openssl )
	zlib? ( sys-libs/zlib )
	qt4? ( x11-libs/qt-core:4 x11-libs/qt-gui:4 )
	spandsp? ( media-libs/spandsp )
	sctp? ( net/sctp-tools )
	zaptel? ( net-misc/zaptel )
"
DEPEND="
	${RDEPEND}
	virtual/pkgconfig
"

S=${WORKDIR}/${PN}

src_prepare() {
#	epatch "${FILESDIR}"/${PN}-4.3.0-ilbc-alsa-oss.patch
	eautoreconf
}

src_configure() {
	# fdsize, inline, rtti: keep default values
	# internalregex: use system
	# coredumper: not in the tree, bug 118716
	# wanpipe, wphwec: not in the tree, bug 188939
	# doxygen, kdoc: no need to rebuild already built doc
	# spandsp >= 0.0.6 fails in configure and >=0.0.5 fails in build
	econf \
		--disable-internalregex \
		--without-coredumper \
		--disable-wanpipe \
		--without-wphwec \
		--without-doxygen \
		--without-kdoc \
		--without-amrnb \
		--with-archlib=$(get_libdir) \
		$(use_with gsm libgsm) \
		$(use_with speex libspeex) \
		$(use_with h323 openh323) \
		$(use_with h323 pwlib) \
		$(use_enable ilbc) \
		$(use_with mysql mysql /usr) \
		$(use_with postgres libpq /usr) \
		$(use_with ssl openssl) \
		$(use_with zlib zlib /usr) \
		$(use_with qt4 libqt4) \
		$(use_with spandsp) \
		$(use_enable sctp) \
		$(use_enable zaptel)
}

src_compile() {
	# fails parallel build, bug #312407
	if use debug; then
		emake -j1 ddebug
	else
		emake -j1
	fi
}

src_test() {
	# there is no real test suite
	# 'make test' tries to execute non-existing ./test
	# do not add RESTRICT="test" because it's not a failing test suite
    :
}

src_install() {
	emake DESTDIR="${D}" install-noapi

	insinto /etc/logrotate.d
	newins packing/${PN}.logrotate ${PN}

	newinitd packing/portage/${PN}.init ${PN} || die "newinitd failed"
	newconfd packing/portage/${PN}.conf ${PN} || die "newconfd failed"

	insinto /usr/share/yate/scripts
	newins "${FILESDIR}"/libyate.rb libyate.rb || die "newins failed"
}
