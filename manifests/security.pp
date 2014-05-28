class apache_anf::security {

  include apache_anf::params

  case $operatingsystem {

    RedHat,CentOS: {
      $manage_module = true
      package { "mod_security":
        ensure => present,
        alias => "apache-mod_security",
      }

      file { "${apache_anf::params::conf}/conf.d/mod_security.conf":
        ensure  => present,
        content => "# file managed by puppet

<IfModule mod_security2.c>
  Include modsecurity.d/modsecurity_localrules.conf
</IfModule>
",
        require => Package["mod_security"],
        notify  => Exec["apache-graceful"],
      }
    }

    Debian: {
      $manage_module = true
      package { "libapache-mod-security":
        ensure => present,
        alias => "apache-mod_security",
      }
    }

    default : {
      $manage_module = false
      notify ( "${modulename} is not supported on ${::operatingsystem}")
    }
  }

  if $manage_module {
    apache_anf::module { ["unique_id", "security"]:
      ensure => present,
      require => Package["apache-mod_security"],
    }
  }

}
