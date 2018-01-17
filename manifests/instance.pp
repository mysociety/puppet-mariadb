# Defined Type: mariadb::instance
#
# @summary This defined type is used to generate instanced systemd service units
#
# This type is used internally when the `$instances` hash is passed to the main
# class to configure arbitrary numbers of instanced versions of the MariaDB service.
#
# It will ensure that each instance has dedicated condifuration, log and data files
# and directories and that the correct instance is notified on changes.
#
# It will also ensure that new instances are provisioned correctly with the
# `mysql_install_db` command.
#
# @param options Configuration options for the instance.
#
define mariadb::instance(
  Hash $options,
) {

  file {
    default:
      owner  => 'root',
      group  => 'root',
      notify => [ Exec['mariadb-systemd-reload'], Service["mariadb@${name}"], ];

    "/etc/mysql/instances/${name}":
      ensure => directory,
      mode   => '0755';

    "/etc/mysql/instances/${name}/my.cnf":
      ensure  => file,
      mode    => '0644',
      content => template('mariadb/50-server.cnf.erb');

    "/etc/mysql/instances/${name}/debian.cnf":
      ensure  => file,
      mode    => '0600',
      content => template('mariadb/debian.cnf.erb');

    $options['mysqld']['datadir']:
      ensure => directory,
      owner  => $options['mysqld']['user'],
      group  => $options['mysqld']['user'],
      mode   => '0755';

    "/var/log/mysql/${name}":
      ensure => directory,
      owner  => $options['mysqld']['user'],
      group  => 'adm',
      mode   => '2740',
  }

  -> exec { "install-mysql-${name}":
    command => "/usr/bin/mysql_install_db --datadir=${options['mysqld']['datadir']} --defaults-file=/etc/mysql/instances/${name}/my.cnf --skip-auth-anonymous-user --auth-root-authentication-method=socket --rpm --cross-bootstrap --user=mysql --disable-log-bin 2>&1 >/dev/null",
    onlyif  => "/usr/bin/test -z \"$( ls -A ${options['mysqld']['datadir']} )\"",
  }

  file { "/etc/logrotate.d/mysql-server-${name}":
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template('mariadb/mysql-server.logrotate.erb'),
  }

  service { "mariadb@${name}":
    ensure     => running,
    enable     => true,
    hasstatus  => true,
    hasrestart => true,
  }

}
