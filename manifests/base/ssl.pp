/*

== Class: apache_anf::base::ssl

Common building blocks between apache_anf::ssl::debian and apache_anf::ssl::redhat.

It shouldn't be necessary to directly include this class.

*/
class apache_anf::base::ssl {

  apache_anf::listen { "443": ensure => present }
  apache_anf::namevhost { "*:443": ensure => present }

  file { "/usr/local/sbin/generate-ssl-cert.sh":
    source => "puppet:///modules/${module_name}/generate-ssl-cert.sh",
    mode   => 755,
  }

}
