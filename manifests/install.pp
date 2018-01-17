# Class: mariadb::install
#
# @summary Private class to install MariDB packages.
#
# This class simply ensures that the contents of the `$packages` array are present.
#
class mariadb::install inherits mariadb {

  ensure_packages($::mariadb::packages, { ensure => present, })

}
