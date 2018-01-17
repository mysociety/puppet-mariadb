# Class: mariadb::config
#
# @summary Private class to configure the core MariaDB server.
#
# For a basic, single instance install, this class uses the `$options` hash to
# configure the primary MariaDB instance.
#
# If the `$instances` hash exists, this is then used to generate additional
# instances of the services using the `mariadb::instance` defined type, taking
# the original `$options` hash as defaults.
#
class mariadb::config inherits mariadb {

  # Override the instance unit as shipped, as we want
  # better separation of configuration.
  file { '/etc/systemd/system/mariadb@.service':
    ensure  => file,
    mode    => '0644',
    owner   => 'root',
    group   => 'root',
    notify  => Exec['mariadb-systemd-reload'],
    content => template('mariadb/mariadb@.service.erb'),
  }

  # Main instance configuration file.
  file { '/etc/mysql/mariadb.conf.d/50-server.cnf':
    ensure  => file,
    mode    => '0644',
    owner   => 'root',
    group   => 'root',
    content => template('mariadb/50-server.cnf.erb'),
  }

  if $::mariadb::instances {
    file { '/etc/mysql/instances': ensure => directory, }
    # Can't use create_resources here, as it doesn't do deep merging right,
    # so we'll use the `deep_merge()` function from stdlib instead.
    $::mariadb::instances.each |String $instance, Hash $opts| {
      ::mariadb::instance { $instance:
        options => deep_merge($::mariadb::options, $opts)
      }
    }
  }

}
