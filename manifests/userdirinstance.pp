define apache::userdirinstance ($ensure=present, $vhost) {

  include apache::params

  file { "${apache::params::vroot}/${vhost}/conf/userdir.conf":
    ensure => $ensure,
    content => template("${module_name}/userdir.erb",
    seltype => $operatingsystem ? {
      "RedHat" => "httpd_config_t",
      "CentOS" => "httpd_config_t",
      default  => undef,
    },
    notify => Exec["apache-graceful"],
  }
}
