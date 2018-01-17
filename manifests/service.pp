# Class: mariadb::service
#
# @summary Private class to manage the primary Mariadb service
#
# This class manages the primary MariaDB service.
#
class mariadb::service inherits mariadb {

  service { 'mariadb':
    ensure     => running,
    enable     => true,
    hasstatus  => true,
    hasrestart => true,
  }

}
