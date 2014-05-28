/*

== Class: apache

Installs apache, ensures a few useful modules are installed (see apache_anf::base),
ensures that the service is running and the logs get rotated.

By including subclasses where distro specific stuff is handled, it ensure that
the apache class behaves the same way on diffrent distributions.

Example usage:

  include apache

*/
class apache_anf {
  case $operatingsystem {
    Debian,Ubuntu:  { include apache_anf::debian}
    RedHat,CentOS:  { include apache_anf::redhat}
    Solaris:        {
      Package { provider => 'pkgutil' }
      include apache_anf::solaris
    }
    default: { fail "Unsupported operatingsystem ${operatingsystem}" }
  }
}
