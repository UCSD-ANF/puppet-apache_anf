class apache::debian inherits apache::base {

  include apache::params

  # BEGIN inheritance from apache::base
  Exec["apache-graceful"] {
    command => "apache2ctl graceful",
    onlyif => "apache2ctl configtest",
  }

  File["logrotate configuration"] {
    path => "/etc/logrotate.d/apache2",
    source => "puppet:///modules/${module_name}/etc/logrotate.d/apache2",
  }

  File["default status module configuration"] {
    path => "${apache::params::conf}/mods-available/status.conf",
    source => "puppet:///modules/${module_name}/etc/apache2/mods-available/status.conf",
  }

  User ['apache user']{
    shell => '/sbin/nologin',
  }
  # END inheritance from apache::base

  $mpm_package = $apache_mpm_type ? {
    "" => "apache2-mpm-prefork",
    default => "apache2-mpm-${apache_mpm_type}",
  }

  package { "${mpm_package}":
    ensure  => installed,
    require => Package["apache"],
  }

  # directory not present in lenny
  file { "${apache::params::vroot}/apache2-default":
    ensure => absent,
    force  => true,
  }

  file { "${apache::params::vroot}/index.html":
    ensure => absent,
  }

  file { "${apache::params::vroot}/html":
    ensure  => directory,
  }

  file { "${apache::params::vroot}/html/index.html":
    ensure  => present,
    owner   => root,
    group   => root,
    mode    => 644,
    content => "<html><body><h1>It works!</h1></body></html>\n",
  }

  file { "${apache::params::conf}/conf.d/servername.conf":
    content => "ServerName ${fqdn}\n",
    notify  => Service["apache"],
    require => Package["apache"],
  }

}
