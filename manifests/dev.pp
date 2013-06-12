#
# == Class: apache::dev
#
# Installs package(s) required to build apache modules using apxs.
#
# Limitation: currently only works on redhat and Solaris with OpenCSW
#
# Example usage:
#
#   include apache::dev
#
class apache::dev {

  $manage_package_requires = $::operatingsystem ? {
    'Solaris'       => Package['gcc4'],
    default         => Package['gcc'],
  }

  $manage_package_name = $::operatingsystem ? {
    /RedHat|CentOS/ => 'httpd-devel',
    Solaris         => 'apache2_dev',
    /Debian|Ubuntu/ => undef, # have to select between mpm and prefork dev pkg
  }

  if $manage_package_name {
    package { "apache-devel":
      name    => $manage_package_name,
      ensure  => present,
      require => $manage_package_requires,
    }
  }
}
