# Copyright 2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

POSTGRES_COMPAT=( {13..17} )

DESCRIPTION="Support for UUIDv7 in PostgreSQL"
HOMEPAGE="https://github.com/fboulnois/pg_uuidv7"
SRC_URI="https://github.com/fboulnois/${PN}/archive/refs/tags/v${PV}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"

DEPEND="dev-db/postgresql:="
RDEPEND="${DEPEND}"
