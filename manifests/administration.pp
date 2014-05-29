class apache_anf::administration {

  include apache_anf::params

  $distro_specific_apache_sudo = $operatingsystem ? {
    /RedHat|CentOS/ => "/usr/sbin/apachectl, /sbin/service ${apache_anf::params::service}",
    /Debian|Ubuntu/ => "/usr/sbin/apache2ctl",
    'Solaris'       => "/opt/csw/apache2/sbin/apachectl, /usr/sbin/svcadm ${apache_anf::params::service}",
  }

  group { "apache-admin":
    ensure => present,
  }

  # used in erb template
  $wwwpkgname = $apache_anf::params::pkg
  $wwwuser    = $apache_anf::params::user

  sudo::directive { "apache-administration":
    ensure => present,
    content => template("apache_anf/sudoers.apache.erb"),
    require => Group["apache-admin"],
  }

}
