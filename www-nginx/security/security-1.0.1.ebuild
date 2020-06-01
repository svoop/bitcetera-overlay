# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6

NG_MOD_LIST=("ngx_http_modsecurity_module.so")

inherit nginx-module git-r3

DESCRIPTION="ModSecurity v3 Nginx connector"
HOMEPAGE="https://www.modsecurity.org"

EGIT_REPO_URI="https://github.com/SpiderLabs/ModSecurity-nginx"

EGIT_COMMIT="v${PV/_/-}"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="systemtap"

DEPEND="
	${CDEPEND}
	>=www-apps/modsecurity-3
"
RDEPEND="${DEPEND}"

DOCS=( "${NG_MOD_WD}"/README.md )

nginx-module-install() {
	use systemtap && (
		insinto /usr/share/systemtap/tapset
		doins ngx-modsec.stp
	)
}
