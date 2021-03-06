class apache_anf::ssl::redhat inherits apache_anf::base::ssl {

  include apache_anf::params
  package {"mod_ssl":
    ensure => installed,
  }

  file {"${apache_anf::params::conf}/conf.d/ssl.conf":
    ensure => absent,
    require => Package["mod_ssl"],
    notify => Service["apache"],
    before => Exec["apache-graceful"],
  }

  apache_anf::module { "ssl":
    ensure => present,
    require => File["${apache_anf::params::conf}/conf.d/ssl.conf"],
    notify => Service["apache"],
    before => Exec["apache-graceful"],
  }

  case $lsbmajdistrelease {
    5,6: {
      file {"${apache_anf::params::conf}/mods-available/ssl.load":
        ensure => present,
        content => template("apache_anf/ssl.load.rhel${lsbmajdistrelease}.erb"),
        mode => 644,
        owner => "root",
        group => "root",
        seltype => "httpd_config_t",
        require => File["${apache_anf::params::conf}/mods-available"],
      }
    }
  }
}
