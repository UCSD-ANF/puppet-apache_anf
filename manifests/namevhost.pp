/*
== Definition: apache_anf::namevhost

Adds a "NameVirtualHost" directive to apache's port.conf file.

Every "ports" parameter you define Apache::Vhost resources should have a
matching NameVirtualHost directive.

Parameters:
- *ensure*: present/absent.
- *name*: ipaddress or ipaddress:port

Requires:
- Class["apache"]

Example usage:

  apache_anf::namevhost { "*:80": }
  apache_anf::namevhost { "127.0.0.1:8080": ensure => present }

*/
define apache_anf::namevhost ($ensure='present') {

  include apache_anf::params

  concat::fragment { "apache-namevhost.conf-${name}":
    ensure  => $ensure,
    target  => "${apache_anf::params::conf}/ports.conf",
    content => "NameVirtualHost ${name}\n",
  }

}
