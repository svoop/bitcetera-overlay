# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit autotools git-r3

DESCRIPTION="Web application firewall (WAF) engine for Apache, IIS and Nginx"
HOMEPAGE="https://www.modsecurity.org"

EGIT_REPO_URI="https://github.com/SpiderLabs/ModSecurity"

EGIT_COMMIT="v${PV/_/-}"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~arm ~arm64 ~x86"
IUSE="afl geoip"

RDEPEND="
	afl? ( app-forensics/afl )
	net-misc/curl
	geoip? ( dev-libs/geoip )
	dev-libs/libxml2
	dev-libs/libpcre
	dev-libs/yajl
"
DEPEND="
	${RDEPEND}
	sys-devel/bison
	sys-devel/flex
"

src_prepare() {
	default
	use afl && export CC=afl-clang-fast CXX=afl-clang-fast++
	eautoreconf
}

src_configure() {
	local myconf

	myconf=(
		$(use_enable afl afl-fuzz)
		$(use_with geoip)
		--enable-parser-generation
		--disable-doxygen-doc
		--disable-examples
		--without-lmdb   # https://github.com/SpiderLabs/ModSecurity/issues/1586
	)

	econf ${myconf[@]}
}
