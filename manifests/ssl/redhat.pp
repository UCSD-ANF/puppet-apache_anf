class apache::ssl::redhat inherits apache::base::ssl {

  include apache::params
  package {"mod_ssl":
    ensure => installed,
  }

  file {"${apache::params::conf}/conf.d/ssl.conf":
    ensure => absent,
    require => Package["mod_ssl"],
    notify => Service["apache"],
    before => Exec["apache-graceful"],
  }

  apache::module { "ssl":
    ensure => present,
    require => File["${apache::params::conf}/conf.d/ssl.conf"],
    notify => Service["apache"],
    before => Exec["apache-graceful"],
  }

  case $lsbmajdistrelease {
    5,6: {
      file {"${apache::params::conf}/mods-available/ssl.load":
        ensure => present,
        content => template("apache/ssl.load.rhel${lsbmajdistrelease}.erb"),
        mode => 644,
        owner => "root",
        group => "root",
        seltype => "httpd_config_t",
        require => File["${apache::params::conf}/mods-available"],
      }
    }
  }
}
