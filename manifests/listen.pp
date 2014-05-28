/*
== Definition: apache_anf::listen

Adds a "Listen" directive to apache's ports.conf file.

Parameters:
- *ensure*: present/absent.
- *name*: port number, or ipaddress:port

Requires:
- Class["apache"]

Example usage:

  apache_anf::listen { "80": }
  apache_anf::listen { "127.0.0.1:8080": ensure => present }

*/
define apache_anf::listen ($ensure='present') {

  include apache_anf::params

  concat::fragment { "apache-ports.conf-${name}":
    ensure  => $ensure,
    target  => "${apache_anf::params::conf}/ports.conf",
    content => "Listen ${name}\n",
  }

}
