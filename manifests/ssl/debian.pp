class apache_anf::ssl::debian inherits apache_anf::base::ssl {

  apache_anf::module {"ssl":
    ensure => present,
  }

  if !defined(Package["ca-certificates"]) {
    package { "ca-certificates":
      ensure => present,
    }
  }
}
