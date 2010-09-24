# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=2

inherit eutils subversion

ESVN_REPO_URI="http://yate.null.ro/svn/yate/trunk"
ESVN_REVISION="3667"

DESCRIPTION="YATE - Yet Another Telephony Engine"
HOMEPAGE="http://yate.null.ro/"
LICENSE="GPL-2"

SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE="doc gsm speex amrnb h323 ilbc mysql postgres ssl qt4 spandsp sctp wanpipe zaptel anonsdp"

DEPEND="
	media-sound/sox
	doc? ( || ( app-doc/doxygen >=dev-util/kdoc-2.0_alpha54 ) )
	gsm? ( media-sound/gsm )
	speex? ( media-libs/speex )
	amrnb? ( media-libs/amrnb )
	h323? ( >=net-libs/openh323-1.15.3 dev-libs/pwlib )
	mysql? ( dev-db/mysql )
	postgres? ( dev-db/postgresql-base )
	ssl? ( dev-libs/openssl )
	qt4? ( x11-libs/qt-core:4 x11-libs/qt-gui:4 )
	spandsp? ( media-libs/spandsp )
	sctp? ( net/sctp-tools )
	wanpipe? ( net-misc/wanpipe )
	zaptel? ( net-misc/zaptel )
"
RDEPEND="${DEPEND}"

S=${WORKDIR}/${PN}

src_unpack() {
	subversion_fetch
}

src_prepare() {
	if use anonsdp; then
		epatch "${FILESDIR}"/anonymous_sdp.patch
	fi
	./autogen.sh || die "autogen.sh failed"
}

src_configure() {
	local configopts
	if use doc; then
		if has_version app-doc/doxygen; then
			configopts+=" --with-doxygen"
		fi
		if has_version dev-util/kdoc; then
			configopts+=" --with-kdoc"
		fi
	else
		configopts+=" --without-doxygen --without-kdoc"
	fi

	econf \
		$(use_enable ilbc) \
		$(use_enable sctp sctp) \
		$(use_with gsm libgsm) \
		$(use_with speex libspeex) \
		$(use_with amrnb amrnb /usr) \
		$(use_with h323 pwlib /usr) \
		$(use_with h323 openh323 /usr) \
		$(use_with mysql mysql /usr) \
		$(use_with postgres libpq /usr) \
		$(use_with ssl openssl) \
		$(use_with qt4 libqt4) \
		$(use_with spandsp) \
		${configopts} || die "Configuring failed"
}

src_compile() {
	emake -j1 all || die "Building failed"
}

src_install() {
	local target
	if use doc; then
		target="install"
	else
		target="install-noapi"
	fi
	emake DESTDIR=${D} ${target} || die "emake ${target} failed"
	newinitd ${S}/packing/portage/yate.init yate
	newconfd ${S}/packing/portage/yate.conf yate

	dodir /var/log/yate || die "dodir failed"
	insinto /etc/logrotate.d
	newins ${S}/packing/yate.logrotate yate || die "newins failed"
}
