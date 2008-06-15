# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit eutils

DESCRIPTION="CallWeaver is a community-driven vendor-independent cross-platform Open Source PBX software project."
HOMEPAGE="http://www.callweaver.org/"

SRC_URI="http://devs.callweaver.org/release/callweaver-${PVR}.tgz"

SLOT="0"
LICENSE="GPL-2"
KEYWORDS="~x86 ~amd64"

# IUSE experimental, not tested appropriately!
# IUSE="ael misdn postgres speex t38 zap exosip fax jabber mgr2 odbc"
IUSE="ael misdn postgres speex t38 zap"

RDEPEND="!net-misc/callweaver-svn
  >=media-libs/spandsp-0.0.5_pre3
  >=sys-libs/libcap-1.10
  misdn? ( =net-dialup/misdn-1.1.2 =net-dialup/misdnuser-1.1.2 )
  speex? ( media-libs/speex )
  postgres? ( dev-db/postgresql )
  zap? ( net-misc/zaptel )"

DEPEND="${RDEPEND}
	sys-devel/flex
	dev-util/subversion
	>=sys-devel/automake-1.9.6
	>=sys-devel/autoconf-2.59
	>=sys-devel/libtool-1.5.20"

src_compile() {
	ewarn "ALL IUSE ARE EXPERIMENTAL, NOT TESTED APPROPRIATELY!"
	epause 5
	econf \
		--libdir=/usr/$(get_libdir)/callweaver	\
		--datadir=/var/lib			\
		--localstatedir=/var			\
		--sharedstatedir=/var/lib/callweaver	\
		--with-directory-layout=lsb		\
		`use_with ael pbx_ael`			\
		`use_with misdn chan_misdn`		\
		`use_with postgres cdr_pgsql`		\
		`use_with postgres res_config_pgsql`	\
		`use_with speex codec_speex`		\
		`use_with t38 app_rxfax`		\
		`use_with t38 app_txfax`		\
		`use_enable t38`			\
		`use_with zap chan_zap`			\
		|| die "configure failed"

#		`use_with exosip chan_exosip`		\
#		`use_with fax chan_fax`			\
#		`use_with fax app_rxfax`		\
#		`use_with fax app_txfax`		\
#		`use_with jabber res_jabber`		\
#		`use_with mgr2 chan_unicall`		\
#		`use_with odbc res_odbc`		\
#		`use_with odbc res_config_odbc`		\
##		`use_enable debug`			\
##		`use_enable profile`			\

	emake || die "make failed"
}

src_install() {
	make DESTDIR="${D}" install || die "make install failed"

	dodoc README INSTALL AUTHORS COPYING NEWS BUGS
	dodoc TODO_FOR_AUTOMAKE SECURITY CREDITS HARDWARE LICENSE

	dodoc doc/README* doc/*.txt doc/*.pdf

	docinto samples
	dodoc "${D}"etc/callweaver/*.sample

	# remove dir
	rm -rf ${D}var/lib/callweaver/doc

	newinitd "${FILESDIR}"/callweaver.rc6	callweaver
	newconfd "${FILESDIR}"/callweaver.confd callweaver

	# don't delete these
	keepdir /var/{log,run,spool}/callweaver
	keepdir /var/lib/callweaver/{images,keys}
}

pkg_preinst() {
	if [[ -z "$(egetent passwd callweaver)" ]]; then
		einfo "Creating callweaver group and user..."
		enewgroup callweaver
		enewuser callweaver -1 -1 /var/lib/callweaver callweaver
	fi
}

pkg_postinst() {
	# only change permissions if callweaver wasn't installed before
	einfo "Fixing permissions..."

	chmod -R u=rwX,g=rX,o=	"${ROOT}"etc/callweaver
	chown -R root:callweaver   "${ROOT}"etc/callweaver

	for x in lib log run spool; do
		chmod -R u=rwX,g=rX,o=	  "${ROOT}"var/${x}/callweaver
		chown -R callweaver:callweaver	"${ROOT}"var/${x}/callweaver
	done
	
	chown -R root:callweaver   "${ROOT}"usr/lib/callweaver
}

pkg_config() {
	# TODO: ask user if he want to reset permissions back to sane defaults
	einfo "Do you want to reset the permissions and ownerships of callweaver to"
	einfo "the default values (y/N)?"
	read res

	res="$(echo $res | tr [[:upper:]] [[:lower:]])"

	if [[ "$res" = "y" ]] || \
	   [[ "$res" = "yes" ]]
	then
		einfo "First time installation, fixing permissions..."

		chmod -R u=rwX,g=rX,o=	"${ROOT}"etc/callweaver
		chown -R root:callweaver   "${ROOT}"etc/callweaver

		for x in lib log run spool; do
			chmod -R u=rwX,g=rX,o=	  "${ROOT}"var/${x}/callweaver
			chown -R callweaver:callweaver	"${ROOT}"var/${x}/callweaver
		done
	fi
}
