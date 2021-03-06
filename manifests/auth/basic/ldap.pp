define apache_anf::auth::basic::ldap (
  $ensure="present", 
  $authname=false,
  $vhost,
  $location="/",
  $authLDAPUrl,
  $authLDAPBindDN=false,
  $authLDAPBindPassword=false,
  $authLDAPCharsetConfig=false,
  $authLDAPCompareDNOnServer=false,
  $authLDAPDereferenceAliases=false,
  $authLDAPGroupAttribute=false,
  $authLDAPGroupAttributeIsDN=false,
  $authLDAPRemoteUserAttribute=false,
  $authLDAPRemoteUserIsDN=false,
  $authzLDAPAuthoritative=false,
  $authzRequire="valid-user"){

  $fname = regsubst($name, "\s", "_", "G")

  include apache_anf::params

  if defined(Apache_anf::Module["ldap"]) {} else {
    apache_anf::module {"ldap": }
  }

  if defined(Apache_anf::Module["authnz_ldap"]) {} else {
    apache_anf::module {"authnz_ldap": }
  }

  if $authname {
    $_authname = $authname
  } else {
    $_authname = $name
  }

  file { "${apache_anf::params::root}/${vhost}/conf/auth-basic-ldap-${fname}.conf":
    ensure => $ensure,
    content => template("apache_anf/auth-basic-ldap.erb"),
    seltype => $operatingsystem ? {
      "RedHat" => "httpd_config_t",
      "CentOS" => "httpd_config_t",
      default  => undef,
    },
    notify => Exec["apache-graceful"],
  }

}
