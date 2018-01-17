# mySociety/mariadb

#### Table of Contents

1. [Description](#description)
1. [Setup](#setup)
    * [What mariadb affects](#what-mariadb-affects)
    * [Setup requirements](#setup-requirements)
    * [Beginning with mariadb](#beginning-with-mariadb)
1. [Usage](#usage)
1. [Reference](#reference)
1. [Limitations](#limitations)
1. [Development](#development)

## Description

This module manages MariaDB and supports running multiple instances side-by-side using `systemd` unit templates.

It should work on recent versions of Debian (>=8) although we've only tested thoroughly on 9. Likewise, it will probably also work OK on Ubuntu.

## Setup

### What mariadb affects

* The MariaDB packages installed, and their related services and configuration files; 
* The module installs an updated template unit file for instances of the `mariadb` service.

### Setup Requirements 

You'll need puppetlabs-stdlib, and also a fairly recent version of Puppet (>= 4.9).

### Beginning with mariadb

```
include mariadb
```

Just doing this will provide a completely vanilla MariaDB installation as if you'd run `apt-get install default-mysql-server`.


## Usage

You'll probably want to override some configuration options at some point. In order to take advantage of this, you'll need to use Hiera. The module sets a merge strategy of `deep` for the `options` hash, so you should be able to safely override individual values:

```
---
classes:
  - mariadb

mariadb::options:
  mysqld:
    max_connections: 1000
    bind_address: "%{::ipaddress}"
```

Configuration options mapped to keys in the `options` hash as-is except for hyphens, which are replaced with underscores.

For multi-instance installs, the `$options` hash will act as defaults for each instance which can be overridden in the `$instances` hash:

```
---
classes:
  - mariadb

mariadb::options:
  mysqld:
    max_connections: 1000
    bind_address: "%{::ipaddress}"

mariadb::instances:
  standby:
    mysqld:
      datadir: /var/lib/mysql-standby
      pid_file: /var/run/mysqld/mysqld-standby.pid
      socket: /var/run/mysqld/mysqld-standby.sock
      log_error: /var/log/mysql/standby/error.log
      log_bin: /var/log/mysql/standby/mysql-bin.log
      port: 3344
      max_connections: 100
```

## Reference

Each class is documented with puppet strings compatible documentation, so you can generate this for more detailed information.

## Limitations

As mentioned above, this module is Debian-specific, uses `systemd` and also assumes a recent version of Puppet.

Not all configuration options have been templated!

## Development

Contributions are more than welcome, please feel free to open issues or even better send pull requests.

