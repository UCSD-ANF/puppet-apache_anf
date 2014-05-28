define apache_anf::vhost (
  $ensure=present,
  $config_file="",
  $config_content=false,
  $htdocs=false,
  $conf=false,
  $readme=false,
  $docroot=false,
  $cgibin=true,
  $user="",
  $admin="",
  $group="",
  $mode=2570,
  $aliases=[],
  $ports=['*:80'],
  $accesslog_format="combined"
) {

  include apache_anf::params

  $wwwuser = $user ? {
    ""      => $apache_anf::params::user,
    default => $user,
  }

  $wwwgroup = $group ? {
    ""      => $apache_anf::params::group,
    default => $group,
  }

  # used in ERB templates
  $wwwroot = $apache_anf::params::vroot

  $documentroot = $docroot ? {
    false   => "${wwwroot}/${name}/htdocs",
    default => $docroot,
  }

  $tmp_cgipath = $cgibin ? {
    true    => "${wwwroot}/${name}/cgi-bin",
    false   => false,
    default => $cgibin,
  }

  # trim trailing slash
  if $tmp_cgipath =~ /(.*)\/$/ {
    $cgipath = $1
  } else {
    $cgipath = $tmp_cgipath
  }

  case $ensure {
    present: {
      file { "${apache_anf::params::conf}/sites-available/${name}":
        ensure  => present,
        owner   => root,
        group   => root,
        mode    => 644,
        seltype => $operatingsystem ? {
          redhat => "httpd_config_t",
          CentOS => "httpd_config_t",
          default => undef,
        },
        require => Package[$apache_anf::params::pkg],
        notify  => Exec["apache-graceful"],
      }

      file { "${apache_anf::params::vroot}/${name}":
        ensure => directory,
        owner  => root,
        group  => root,
        mode   => 755,
        seltype => $operatingsystem ? {
          redhat => "httpd_sys_content_t",
          CentOS => "httpd_sys_content_t",
          default => undef,
        },
        require => File["vroot directory"],
      }

      file { "${apache_anf::params::vroot}/${name}/conf":
        ensure => directory,
        owner  => $admin ? {
          "" => $wwwuser,
          default => $admin,
        },
        group  => $wwwgroup,
        mode   => $mode,
        seltype => $operatingsystem ? {
          redhat => "httpd_config_t",
          CentOS => "httpd_config_t",
          default => undef,
        },
        require => [File["${apache_anf::params::vroot}/${name}"]],
      }

      file { "${apache_anf::params::vroot}/${name}/htdocs":
        ensure => directory,
        owner  => $wwwuser,
        group  => $wwwgroup,
        mode   => $mode,
        seltype => $operatingsystem ? {
          redhat => "httpd_sys_content_t",
          CentOS => "httpd_sys_content_t",
          default => undef,
        },
        require => [File["${apache_anf::params::vroot}/${name}"]],
      }
 
      if $htdocs {
        File["${apache_anf::params::vroot}/${name}/htdocs"] {
          source  => $htdocs,
          recurse => true,
        }
      }

      if $conf {
        File["${apache_anf::params::vroot}/${name}/conf"] {
          source  => $conf,
          recurse => true,
        }
      }

      # cgi-bin
      file { "${name} cgi-bin directory":
        path   => $cgipath ? {
          false   => "${apache_anf::params::vroot}/${name}/cgi-bin/",
          default => $cgipath,
        },
        ensure => $cgipath ? {
          "${apache_anf::params::vroot}/${name}/cgi-bin/" => directory,
          default => undef, # don't manage this directory unless under $root/$name
        },
        owner  => $wwwuser,
        group  => $wwwgroup,
        mode   => $mode,
        seltype => $operatingsystem ? {
          redhat => "httpd_sys_script_exec_t",
          CentOS => "httpd_sys_script_exec_t",
          default => undef,
        },
        require => [File["${apache_anf::params::vroot}/${name}"]],
      }

      case $config_file {

        default: {
          File["${apache_anf::params::conf}/sites-available/${name}"] {
            source => $config_file,
          }
        }
        "": {

          if $config_content {
            File["${apache_anf::params::conf}/sites-available/${name}"] {
              content => $config_content,
            }
          } else {
            # default vhost template
            File["${apache_anf::params::conf}/sites-available/${name}"] {
              content => template("apache/vhost.erb"),
            }
          }
        }
      }

      # Log files
      file {"${apache_anf::params::vroot}/${name}/logs":
        ensure => directory,
        owner  => root,
        group  => root,
        mode   => 755,
        seltype => $operatingsystem ? {
          redhat => "httpd_log_t",
          CentOS => "httpd_log_t",
          default => undef,
        },
        require => File["${apache_anf::params::vroot}/${name}"],
      }

      # We have to give log files to right people with correct rights on them.
      # Those rights have to match those set by logrotate
      file { ["${apache_anf::params::vroot}/${name}/logs/access.log",
              "${apache_anf::params::vroot}/${name}/logs/error.log"] :
        ensure => present,
        owner => root,
        group => adm,
        mode => 644,
        seltype => $operatingsystem ? {
          redhat => "httpd_log_t",
          CentOS => "httpd_log_t",
          default => undef,
        },
        require => File["${apache_anf::params::vroot}/${name}/logs"],
      }

      # Private data
      file {"${apache_anf::params::vroot}/${name}/private":
        ensure  => directory,
        owner   => $wwwuser,
        group   => $wwwgroup,
        mode    => $mode,
        seltype => $operatingsystem ? {
          redhat => "httpd_sys_content_t",
          CentOS => "httpd_sys_content_t",
          default => undef,
        },
        require => File["${apache_anf::params::vroot}/${name}"],
      }

      # README file
      file {"${apache_anf::params::vroot}/${name}/README":
        ensure  => present,
        owner   => root,
        group   => root,
        mode    => 644,
        content => $readme ? {
          false => template("apache/README_vhost.erb"),
          default => $readme,
        },
        require => File["${apache_anf::params::vroot}/${name}"],
      }

      exec {"enable vhost ${name}":
        command => $operatingsystem ? {
          RedHat => "${apache_anf::params::a2ensite} ${name}",
          CentOS => "${apache_anf::params::a2ensite} ${name}",
          default => "${apache_anf::params::a2ensite} ${name}"
        },
        notify  => Exec["apache-graceful"],
        require => [$operatingsystem ? {
          redhat => File["${apache_anf::params::a2ensite}"],
          CentOS => File["${apache_anf::params::a2ensite}"],
          default => Package[$apache_anf::params::pkg]},
          File["${apache_anf::params::conf}/sites-available/${name}"],
          File["${apache_anf::params::vroot}/${name}/htdocs"],
          File["${apache_anf::params::vroot}/${name}/logs"],
          File["${apache_anf::params::vroot}/${name}/conf"]
        ],
        unless  => "/bin/bash -c '[ -L ${apache_anf::params::conf}/sites-enabled/${name} ] \\
          && [ ${apache_anf::params::conf}/sites-enabled/${name} -ef ${apache_anf::params::conf}/sites-available/${name} ]'",
      }
    }

    absent:{
      file { "${apache_anf::params::conf}/sites-enabled/${name}":
        ensure  => absent,
        require => Exec["disable vhost ${name}"]
      }

      file { "${apache_anf::params::conf}/sites-available/${name}":
        ensure  => absent,
        require => Exec["disable vhost ${name}"]
      }

      exec { "remove ${apache_anf::params::vroot}/${name}":
        command => "rm -rf ${apache_anf::params::vroot}/${name}",
        onlyif  => "test -d ${apache_anf::params::vroot}/${name}",
        require => Exec["disable vhost ${name}"],
      }

      exec { "disable vhost ${name}":
        command => $operatingsystem ? {
          RedHat => "/usr/local/sbin/a2dissite ${name}",
          CentOS => "/usr/local/sbin/a2dissite ${name}",
          default => "/usr/sbin/a2dissite ${name}"
        },
        notify  => Exec["apache-graceful"],
        require => [$operatingsystem ? {
          redhat => File["${apache_anf::params::a2ensite}"],
          CentOS => File["${apache_anf::params::a2ensite}"],
          default => Package[$apache_anf::params::pkg]}],
        onlyif => "/bin/bash -c '[ -L ${apache_anf::params::conf}/sites-enabled/${name} ] \\
          && [ ${apache_anf::params::conf}/sites-enabled/${name} -ef ${apache_anf::params::conf}/sites-available/${name} ]'",
      }
   }

   disabled: {
      exec { "disable vhost ${name}":
        command => "a2dissite ${name}",
        notify  => Exec["apache-graceful"],
        require => Package[$apache_anf::params::pkg],
        onlyif => "/bin/bash -c '[ -L ${apache_anf::params::conf}/sites-enabled/${name} ] \\
          && [ ${apache_anf::params::conf}/sites-enabled/${name} -ef ${apache_anf::params::conf}/sites-available/${name} ]'",
      }

      file { "${apache_anf::params::conf}/sites-enabled/${name}":
        ensure  => absent,
        require => Exec["disable vhost ${name}"]
      }
    }
    default: { err ( "Unknown ensure value: '${ensure}'" ) }
  }
}
