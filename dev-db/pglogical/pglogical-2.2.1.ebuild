# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI="6"

inherit eutils multilib versionator

MY_PV=$(replace_all_version_separators '_')
MY_P="${PN}-${MY_PV}"
S="${WORKDIR}/${PN}-REL${MY_PV}"

DESCRIPTION="Logical replication for PostgreSQL"
HOMEPAGE="https://www.2ndquadrant.com/en/resources/pglogical/"
SRC_URI="https://github.com/2ndQuadrant/pglogical/archive/REL${MY_PV}.tar.gz"

LICENSE="POSTGRESQL"
SLOT="0"
KEYWORDS="amd64"
IUSE=""

DEPEND=">=dev-db/postgresql-9.4[server,static-libs]"
RDEPEND="${DEPEND}"

src_compile() {
  emake USE_PGXS=1 || die "emake failed"
}

src_install() {
	emake DESTDIR="${D}" USE_PGXS=1 install
	dobin pglogical_create_subscriber
}
