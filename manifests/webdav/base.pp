class apache_anf::webdav::base {

  case $operatingsystem {

    Debian,Ubuntu:  {

      package {"libapache2-mod-encoding":
        ensure => present,
      }

      apache_anf::module {"encoding":
        ensure  => present,
        require => Package["libapache2-mod-encoding"],
      }

    /* Other OS: If you encounter issue with encoding, read the description of
       the Debian package:
       http://packages.debian.org/squeeze/libapache2-mod-encoding
    */

    }

  }

  apache_anf::module {["dav", "dav_fs"]:
    ensure => present,
  }

  if !defined(Apache_anf::Module["headers"]) {
    apache_anf::module {"headers":
      ensure => present,
    }
  }

}
