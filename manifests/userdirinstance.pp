define apache_anf::userdirinstance ($ensure=present, $vhost) {

  include apache_anf::params

  file { "${apache_anf::params::vroot}/${vhost}/conf/userdir.conf":
    ensure => $ensure,
    content => template("${module_name}/userdir.erb"),
    seltype => $operatingsystem ? {
      "RedHat" => "httpd_config_t",
      "CentOS" => "httpd_config_t",
      default  => undef,
    },
    notify => Exec["apache-graceful"],
  }
}
