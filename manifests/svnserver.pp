class apache_anf::svnserver inherits apache_anf::ssl {

  case $operatingsystem {

    Debian,Ubuntu:  {
      $pkglist = [ 'libapache2-svn' ]
    }

    RedHat,CentOS:  {
      $pkglist = [ 'mod_dav_svn' ]
    }

    default: {
      fail "Unsupported operatingsystem ${operatingsystem}"
    }

  }

  package {
    $pkglist:
    ensure => present,
  }

  apache_anf::module {
    [
      "dav",
      "dav_svn",
    ]:
    ensure  => present,
    require => Package[ $pkglist ],
  }

}
