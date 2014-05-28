#
# == Class: apache_anf::dev
#
# Installs package(s) required to build apache modules using apxs.
#
# Limitation: currently only works on redhat and Solaris with OpenCSW
#
# Example usage:
#
#   include apache_anf::dev
#
class apache_anf::dev {

  $manage_package_requires = $::osfamily ? {
    'Solaris'       => Package['gcc4'],
    default         => Package['gcc'],
  }

  $manage_package_name = $::osfamily ? {
    'RedHat'  => 'httpd-devel',
    'Solaris' => 'apache2_dev',
    'Debian'  => undef, # have to select between mpm and prefork dev pkg
  }

  if $manage_package_name {
    package { "apache-devel":
      name    => $manage_package_name,
      ensure  => present,
      require => $manage_package_requires,
    }
  }
}
