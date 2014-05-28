define apache_anf::webdav::svn ($ensure, $vhost, $parentPath, $confname) {

  include apache_anf::params

  $location = $name

  file { "${apache_anf::params::root}/${vhost}/conf/${confname}.conf":
    ensure  => $ensure,
    content => template("apache/webdav-svn.erb"),
    seltype => $operatingsystem ? {
      "RedHat" => "httpd_config_t",
      "CentOS" => "httpd_config_t",
      default  => undef,
    },
    notify  => Exec["apache-graceful"],
  }

}
