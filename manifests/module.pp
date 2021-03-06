define apache_anf::module ($ensure='present') {

  include apache_anf::params

  $a2enmod_deps = $operatingsystem ? {
    /RedHat|CentOS|Solaris/ => [
      Package["apache"],
      File["${apache_anf::params::conf}/mods-available"],
      File["${apache_anf::params::conf}/mods-enabled"],
      File["/usr/local/sbin/a2enmod"],
      File["/usr/local/sbin/a2dismod"]
    ],
    /Debian|Ubuntu/ => Package["apache"],
  }

  if $selinux == "true" {
    apache_anf::redhat::selinux {$name: }
  }

  case $ensure {
    'present' : {
      exec { "a2enmod ${name}":
        command => $operatingsystem ? {
          /RedHat|CentOS/ => "/usr/local/sbin/a2enmod ${name}",
          Solaris         => "/usr/local/sbin/a2enmod ${name}",
          default         => "/usr/sbin/a2enmod ${name}"
        },
        unless  => "/bin/bash -c '[ -L ${apache_anf::params::conf}/mods-enabled/${name}.load ] \\
          && [ ${apache_anf::params::conf}/mods-enabled/${name}.load -ef ${apache_anf::params::conf}/mods-available/${name}.load ]'",
        require => $a2enmod_deps,
        notify  => Service["apache"],
      }
    }

    'absent': {
      exec { "a2dismod ${name}":
        command => $operatingsystem ? {
          /RedHat|CentOS/ => "/usr/local/sbin/a2dismod ${name}",
          Solaris         => "/usr/local/sbin/a2dismod ${name}",
          /Debian|Ubuntu/ => "/usr/sbin/a2dismod ${name}",
        },
        onlyif  => "/bin/bash -c '[ -L ${apache_anf::params::conf}/mods-enabled/${name}.load ] \\
          || [ -e ${apache_anf::params::conf}/mods-enabled/${name}.load ]'",
        require => $a2enmod_deps,
        notify  => Service["apache"],
       }
    }

    default: {
      err ( "Unknown ensure value: '${ensure}'" )
    }
  }
}
