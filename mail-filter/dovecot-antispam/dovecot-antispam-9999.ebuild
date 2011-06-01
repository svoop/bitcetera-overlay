# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: Exp $

EAPI=2

inherit base mercurial

DESCRIPTION="A dovecot antispam plugin supporting multiple backends"
HOMEPAGE="http://wiki2.dovecot.org/Plugins/Antispam"

EHG_REPO_URI="http://hg.dovecot.org/dovecot-antispam-plugin"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE=""

DEPEND=">=net-mail/dovecot-2"
RDEPEND="${DEPEND}"

S="${WORKDIR}/dovecot-antispam-plugin"

src_prepare() {
	# kludge for missing EHG_BOOTSTRAP, see https://bugs.gentoo.org/show_bug.cgi?id=340153
	cd "${S}"
	./autogen.sh
}
