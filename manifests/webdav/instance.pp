define apache_anf::webdav::instance ($ensure=present, $vhost, $directory=false,$mode=2755) {

  include apache_anf::params
 
  if $directory {
    $davdir = "${directory}/webdav-${name}"
  } else {
    $davdir = "${apache_anf::params::root}/${vhost}/private/webdav-${name}"
  }

  file {$davdir:
    ensure => $ensure ? {
      present => directory,
      absent  => absent,
    },
    owner => "www-data",
    group => "www-data",
    mode => $mode,
  }

  # configuration
  file { "${apache_anf::params::root}/${vhost}/conf/webdav-${name}.conf":
    ensure => $ensure,
    content => template("apache_anf/webdav-config.erb"),
    seltype => $operatingsystem ? {
      "RedHat" => "httpd_config_t",
      "CentOS" => "httpd_config_t",
      default  => undef,
    },
    require => File[$davdir],
    notify => Exec["apache-graceful"],
  }

}
