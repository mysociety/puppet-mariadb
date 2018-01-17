# Class: mariadb
#
# @summary A module to manage MariaDB that supports multiple instances
#
# This class acts as the gateway for the module. All parameters are passed in here
# and inherited elsewhere in the module.
#
# The module is designed to take advantage of automatic parameter lookup and deep
# merging via Hiera, although you could contstruct a complete data structure and
# pass this in as explicit parameters.
#
# @param packages List of packages to install
# @param options Nested hash of options to set in config files. Each later should correspond to a section in the conifig file. Currrently only support [mysqld]. Also note that hyphens in config file params are replaced with underscores.
# @param instances This should contain a hash of instance names which in turn contains a hash of overrides for the options hash. The module-level options hash is used for defaults.
#
# @example A simple install of a single server with defaults.
#    class { 'mariadb': }
#
# @author Sam Pearson <sam@mysociety.org>
#
class mariadb(
  Array $packages,
  Hash $options,
  Optional[Hash] $instances,
) {

  # There's no global way of doing this, I think.
  # This should ensure that systemd gets reloaded before
  # any service actions.
  Exec['mariadb-systemd-reload'] -> Service <||>
  exec { 'mariadb-systemd-reload':
    command     => '/bin/systemctl daemon-reload',
    refreshonly => true,
  }

  contain mariadb::install
  contain mariadb::config
  contain mariadb::service

  Class['::mariadb::install']
  -> Class['::mariadb::config']
  ~> Class['::mariadb::service']

}
