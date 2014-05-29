define apache_anf::auth::basic::file::group (
  $ensure="present", 
  $authname=false,
  $vhost,
  $location="/",
  $authUserFile=false,
  $authGroupFile=false,
  $groups){

  $fname = regsubst($name, "\s", "_", "G")

  include apache_anf::params
 
  if defined(Apache_anf::Module["authn_file"]) {} else {
    apache_anf::module {"authn_file": }
  }

  if $authUserFile {
    $_authUserFile = $authUserFile
  } else {
    $_authUserFile = "${apache_anf::params::root}/${vhost}/private/htpasswd"
  }

  if $authGroupFile {
    $_authGroupFile = $authGroupFile
  } else {
    $_authGroupFile = "${apache_anf::params::root}/${vhost}/private/htgroup"
  }

  if $authname {
    $_authname = $authname
  } else {
    $_authname = $name
  }

  file { "${apache_anf::params::root}/${vhost}/conf/auth-basic-file-group-${fname}.conf":
    ensure => $ensure,
    content => template("apache/auth-basic-file-group.erb"),
    seltype => $operatingsystem ? {
      "RedHat" => "httpd_config_t",
      "CentOS" => "httpd_config_t",
      default  => undef,
    },
    notify => Exec["apache-graceful"],
  }

}
