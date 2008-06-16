# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit eutils

DESCRIPTION="OTPW is a one-time password list generator and verifier including a wrapper suitable for PAM."
HOMEPAGE="http://www.cl.cam.ac.uk/~mgk25/otpw.html"

SRC_URI="http://www.cl.cam.ac.uk/~mgk25/download/otpw-snapshot.tar.gz"

SLOT="0"
LICENSE="GPL-2"
KEYWORDS="~amd64"

IUSE="pam pic"

RDEPEND="pam? ( sys-libs/pam )"

DEPEND="${RDEPEND}"

src_compile() {
eerror "Under construction, not ready for use quite yet."
die
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
