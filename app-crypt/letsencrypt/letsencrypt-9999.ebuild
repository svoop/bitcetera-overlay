# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

PYTHON_COMPAT=( python{2_6,2_7} )

inherit eutils git-r3 distutils-r1

DESCRIPTION="ACME client"
HOMEPAGE="https://letsencrypt.org/"
SRC_URI=""
EGIT_REPO_URI="https://github.com/letsencrypt/letsencrypt.git"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND="
	dev-python/virtualenv
	dev-lang/python
	dev-python/setuptools
	sys-devel/gcc
	dev-lang/swig
	dev-util/dialog
	dev-python/python-augeas
	dev-libs/openssl
	dev-python/pyopenssl
	virtual/libffi
	app-misc/ca-certificates
	"

RDEPEND=""

python_compile() {
	distutils-r1_python_compile
}

python_install_all() {
	distutils-r1_python_install_all
}
