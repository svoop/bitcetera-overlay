# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit eutils

DESCRIPTION="Community-driven vendor-independent cross-platform Open Source PBX software."
HOMEPAGE="http://www.callweaver.org/"
SRC_URI="http://devs.callweaver.org/release/callweaver-${PVR}.tgz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="ael dahdi debug fax jabber misdn mgr2 mysql odbc postgres profile speex t38 zap zaptel"

RDEPEND="!net-misc/callweaver-svn
	=media-libs/spandsp-0.0.5_pre4
	>=sys-libs/libcap-1.10
	dahdi? ( net-misc/zaptel )
	misdn? ( >=net-dialup/misdn-1.1.7 >=net-dialup/misdnuser-1.1.7 )
	speex? ( media-libs/speex )
	mysql? ( dev-db/mysql )
	postgres? ( dev-db/postgresql )
	zap? ( net-misc/zaptel )
	zaptel? ( net-misc/zaptel )"

DEPEND="${RDEPEND}
	sys-devel/flex
	>=sys-devel/automake-1.9.6
	>=sys-devel/autoconf-2.59
	>=sys-devel/libtool-1.5.20"

src_compile() {
	ewarn "All USE flags are experimental, please submit issues and patches to:"
	ewarn "http://bugs.gentoo.org/buglist.cgi?quicksearch=callweaver"
	epause 5
	econf \
		--libdir=/usr/$(get_libdir)/callweaver	\
		--datadir=/var/lib			\
		--localstatedir=/var			\
		--sharedstatedir=/var/lib/callweaver	\
		--with-directory-layout=lsb		\
		$(use_with ael pbx_ael)			\
		$(use_with dahdi chan_zap)		\
		$(use_with fax chan_fax)		\
		$(use_with fax app_rxfax)		\
		$(use_with fax app_txfax)		\
		$(use_with jabber res_jabber)		\
		$(use_with misdn chan_misdn)		\
		$(use_with mgr2 chan_unicall)		\
		$(use_with mysql cdr_mysql)		\
		$(use_with mysql res_config_mysql)	\
		$(use_with odbc res_odbc)		\
		$(use_with odbc res_config_odbc)	\
		$(use_with postgres cdr_pgsql)		\
		$(use_with postgres res_config_pgsql)	\
		$(use_with speex codec_speex)		\
		$(use_with t38 app_rxfax)		\
		$(use_with t38 app_txfax)		\
		$(use_with zap chan_zap)		\
		$(use_with zaptel chan_zap)		\
		$(use_enable debug)			\
		$(use_enable profile)			\
		$(use_enable t38)			\
		|| die "configure failed"
	emake || die "emake failed"
}

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed"

	dodoc README INSTALL AUTHORS NEWS BUGS
	dodoc TODO_FOR_AUTOMAKE SECURITY CREDITS HARDWARE
	dodoc doc/README* doc/*.txt doc/*.pdf

	docinto samples
	dodoc "${D}"etc/callweaver/*.sample

	rm -rf "${D}"var/lib/callweaver/doc

	newinitd "${FILESDIR}"/callweaver.rc6 callweaver
	newconfd "${FILESDIR}"/callweaver.confd callweaver

	keepdir /var/{log,run,spool}/callweaver
	keepdir /var/lib/callweaver/{images,keys}
}

pkg_preinst() {
	if [[ -z "$(egetent passwd callweaver)" ]]; then
		elog "Creating callweaver group and user..."
		enewgroup callweaver
		enewuser callweaver -1 -1 /var/lib/callweaver callweaver
	fi
}

pkg_postinst() {
	elog "Fixing permissions..."

	chmod -R u=rwX,g=rX,o= "${ROOT}"etc/callweaver
	chown -R root:callweaver "${ROOT}"etc/callweaver

	for x in lib log run spool; do
		chmod -R u=rwX,g=rX,o= "${ROOT}"var/${x}/callweaver
		chown -R callweaver:callweaver "${ROOT}"var/${x}/callweaver
	done

	chown -R root:callweaver "${ROOT}"usr/lib/callweaver

	if use zap; then
		ewarn "The Zaptel project has been renamed to DAHDI. Please replace the USE"
		ewarn "flag 'zap' with 'dahdi' now."
		ewarn "http://blogs.digium.com/2008/05/19"
	fi

	if use zaptel; then
		ewarn "The Zaptel project has been renamed to DAHDI. Please replace the USE"
		ewarn "flag 'zaptel' with 'dahdi' now."
		ewarn "http://blogs.digium.com/2008/05/19"
	fi
}

pkg_config() {
	elog "Do you want to reset the permissions and ownerships of callweaver to"
	elog "the default values (y/N)?"
	read res

	res="$(echo $res | tr [[:upper:]] [[:lower:]])"

	if [[ "$res" = "y" ]] || [[ "$res" = "yes" ]]; then
		elog "First time installation, fixing permissions..."

		chmod -R u=rwX,g=rX,o= "${ROOT}"etc/callweaver
		chown -R root:callweaver "${ROOT}"etc/callweaver

		for x in lib log run spool; do
			chmod -R u=rwX,g=rX,o= "${ROOT}"var/${x}/callweaver
			chown -R callweaver:callweaver "${ROOT}"var/${x}/callweaver
		done
	fi
}
