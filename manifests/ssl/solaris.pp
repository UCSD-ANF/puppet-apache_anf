class apache::ssl::solaris inherits apache::base::ssl {
  file {"${apache::params::conf}/conf.d/ssl.conf":
    ensure => absent,
    require => Package["apache"],
    notify => Service["apache"],
    before => Exec["apache-graceful"],
  }

  apache::module { "ssl":
    ensure => present,
    require => File["${apache::params::conf}/conf.d/ssl.conf"],
    notify => Service["apache"],
    before => Exec["apache-graceful"],
  }

  file {"${apache::params::conf}/mods-available/ssl.load":
    ensure => present,
    content => template("apache/ssl.load.solaris.erb"),
    mode => 644,
    owner => "root",
    group => "root",
    require => File["${apache::params::conf}/mods-available"],
  }
}
