# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

EGO_PN="github.com/joohoi/${PN}"

inherit fcaps golang-vcs-snapshot-r1 user

DESCRIPTION="A simplified DNS server with a RESTful HTTP API to provide ACME DNS challenges"
HOMEPAGE="https://github.com/joohoi/acme-dns"
SRC_URI="https://${EGO_PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"
RESTRICT="mirror"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="debug pie postgres +sqlite static"
REQUIRED_USE="|| ( postgres sqlite )"

RDEPEND="
	postgres? ( dev-db/postgresql )
	sqlite? ( dev-db/sqlite:3 )
"

FILECAPS=( cap_net_bind_service+ep usr/bin/acme-dns )

DOCS=( README.md )
QA_PRESTRIPPED="usr/bin/.*"

G="${WORKDIR}/${P}"
S="${G}/src/${EGO_PN}"

pkg_setup() {
	enewgroup acme-dns
	enewuser acme-dns -1 -1 /var/lib/acme-dns acme-dns
}

src_compile() {
	export GOPATH="${G}"
	export CGO_CFLAGS="${CFLAGS}"
	export CGO_LDFLAGS="${LDFLAGS}"
	(use static && ! use pie) && export CGO_ENABLED=0
	(use static && use pie) && CGO_LDFLAGS+=" -static"

	# build up optional flags
	use postgres && opts+=" postgres"
	use sqlite && opts+=" sqlite3"
	use static && opts+=" netgo"

	local mygoargs=(
		-v -work -x
		-buildmode "$(usex pie pie exe)"
		-asmflags "all=-trimpath=${S}"
		-gcflags "all=-trimpath=${S}"
		-ldflags "$(usex !debug '-s -w' '')"
		-tags "${opts/ /}"
		-installsuffix "$(usex static 'netgo' '')"
	)
	go build "${mygoargs[@]}" || die
}

src_install() {
	dobin acme-dns
	use debug && dostrip -x /usr/bin/acme-dns
	einstalldocs

	newinitd "${FILESDIR}/${PN}.initd" "${PN}"
	newconfd "${FILESDIR}/${PN}.confd" "${PN}"

	insinto /var/lib/acme-dns
	newins config.cfg config.cfg.example

	diropts -o acme-dns -g acme-dns -m 0750
	keepdir /var/log/acme-dns
}

pkg_postinst() {
	fcaps_pkg_postinst

	if ! use filecaps; then
		ewarn
		ewarn "'filecaps' USE flag is disabled"
		ewarn "${PN} will fail to listen on port 53"
		ewarn "please either change port to > 1024 or re-enable 'filecaps'"
		ewarn
	fi
}
