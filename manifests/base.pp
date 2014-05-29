/*

== Class: apache_anf::base

Common building blocks between apache_anf::debian and apache_anf::redhat.

It shouldn't be necessary to directly include this class.

*/
class apache_anf::base {

  include apache_anf::params
  include concat::setup

  $access_log = $apache_anf::params::access_log
  $error_log  = $apache_anf::params::error_log

  concat {"${apache_anf::params::conf}/ports.conf":
    notify  => Service['apache'],
    require => Package['apache'],
  }

  # removed this folder originally created by common::concatfilepart
  file {"${apache_anf::params::conf}/ports.conf.d":
    ensure  => absent,
    purge   => true,
    recurse => true,
    force   => true,
  }

  file {"vroot directory":
    path => $apache_anf::params::vroot,
    ensure => directory,
    mode => 755,
    owner => "root",
    group => "root",
    require => Package["apache"],
  }

  file {"log directory":
    path => $apache_anf::params::log,
    ensure => directory,
    mode => 700,
    owner => "root",
    group  => "root",
    require => Package["apache"],
  }

  user { "apache user":
    name    => $apache_anf::params::user,
    ensure  => present,
    require => Package["apache"],
  }

  group { "apache group":
    name    => $apache_anf::params::group,
    ensure  => present,
    require => Package["apache"],
  }

  package { "apache":
    name   => $apache_anf::params::pkg,
    ensure => installed,
  }

  service { "apache":
    name       => $apache_anf::params::service,
    ensure     => running,
    enable     => true,
    hasrestart => true,
    require    => Package["apache"],
  }

  file {"logrotate configuration":
    path => undef,
    ensure => present,
    owner => root,
    group => root,
    mode => 644,
    source => undef,
    require => Package["apache"],
  }

  apache_anf::listen { "80": ensure => present }
  apache_anf::namevhost { "*:80": ensure => present }

  apache_anf::module {["alias", "auth_basic", "authn_file", "authz_default", "authz_groupfile", "authz_host", "authz_user", "autoindex", "dir", "env", "mime", "negotiation", "rewrite", "setenvif", "status", "cgi"]:
    ensure => present,
    notify => Exec["apache-graceful"],
  }

  file {"default status module configuration":
    path => undef,
    ensure => present,
    owner => root,
    group => root,
    source => undef,
    require => Module["status"],
    notify => Exec["apache-graceful"],
  }

  file {"default virtualhost":
    path    => "${apache_anf::params::conf}/sites-available/default-vhost",
    ensure  => present,
    content => template("apache_anf/default-vhost.erb"),
    require => Package["apache"],
    notify  => Exec["apache-graceful"],
    before  => File["${apache_anf::params::conf}/sites-enabled/000-default-vhost"],
    mode    => 644,
  }

  if $apache_disable_default_vhost {
    file { "${apache_anf::params::conf}/sites-enabled/000-default-vhost":
      ensure => absent,
      notify => Exec['apache-graceful'],
    }
  } else {
    file { "${apache_anf::params::conf}/sites-enabled/000-default-vhost":
      ensure => link,
      target => "${apache_anf::params::conf}/sites-available/default-vhost",
      notify => Exec['apache-graceful'],
    }
  }

  exec { "apache-graceful":
    command => undef,
    refreshonly => true,
    onlyif => undef,
  }

  file {"/usr/local/bin/htgroup":
    ensure => present,
    owner => root,
    group => root,
    mode => 755,
    source => "puppet:///modules/${module_name}/usr/local/bin/htgroup",
  }

  file { ["${apache_anf::params::conf}/sites-enabled/default",
          "${apache_anf::params::conf}/sites-enabled/000-default",
          "${apache_anf::params::conf}/sites-enabled/default-ssl"]:
    ensure => absent,
    notify => Exec["apache-graceful"],
  }

}
