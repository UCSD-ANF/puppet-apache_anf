class apache_anf::debian inherits apache_anf::base {

  include apache_anf::params

  # BEGIN inheritance from apache_anf::base
  Exec["apache-graceful"] {
    command => "apache2ctl graceful",
    onlyif => "apache2ctl configtest",
  }

  File["logrotate configuration"] {
    path => "/etc/logrotate.d/apache2",
    source => "puppet:///modules/${module_name}/etc/logrotate.d/apache2",
  }

  File["default status module configuration"] {
    path => "${apache_anf::params::conf}/mods-available/status.conf",
    source => "puppet:///modules/${module_name}/etc/apache2/mods-available/status.conf",
  }

  User ['apache user']{
    shell => '/sbin/nologin',
  }
  # END inheritance from apache_anf::base

  $mpm_package = $apache_mpm_type ? {
    "" => "apache2-mpm-prefork",
    default => "apache2-mpm-${apache_mpm_type}",
  }

  package { "${mpm_package}":
    ensure  => installed,
    require => Package["apache"],
  }

  # directory not present in lenny
  file { "${apache_anf::params::vroot}/apache2-default":
    ensure => absent,
    force  => true,
  }

  file { "${apache_anf::params::vroot}/index.html":
    ensure => absent,
  }

  file { "${apache_anf::params::vroot}/html":
    ensure  => directory,
  }

  file { "${apache_anf::params::vroot}/html/index.html":
    ensure  => present,
    owner   => root,
    group   => root,
    mode    => 644,
    content => "<html><body><h1>It works!</h1></body></html>\n",
  }

  file { "${apache_anf::params::conf}/conf.d/servername.conf":
    content => "ServerName ${fqdn}\n",
    notify  => Service["apache"],
    require => Package["apache"],
  }

}
