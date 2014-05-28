class apache_anf::ssl::solaris inherits apache_anf::base::ssl {
  file {"${apache_anf::params::conf}/conf.d/ssl.conf":
    ensure => absent,
    require => Package["apache"],
    notify => Service["apache"],
    before => Exec["apache-graceful"],
  }

  apache_anf::module { "ssl":
    ensure => present,
    require => File["${apache_anf::params::conf}/conf.d/ssl.conf"],
    notify => Service["apache"],
    before => Exec["apache-graceful"],
  }

  file {"${apache_anf::params::conf}/mods-available/ssl.load":
    ensure => present,
    content => template("apache/ssl.load.solaris.erb"),
    mode => 644,
    owner => "root",
    group => "root",
    require => File["${apache_anf::params::conf}/mods-available"],
  }
}
