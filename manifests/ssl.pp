/*

== Class: apache_anf::ssl

This class basically does the same thing the "apache" class does + enable
mod_ssl.

It also drops a little shell script in /usr/local/sbin/generate-ssl-cert.sh,
which is used by apache_anf::vhost-ssl to generate an SSL key and certificate. This
script calls openssl with /var/www/<vhost>/ssl/ssleay.cnf as a template. The
content of this file is influenced by a few class variables described below.

Class variables:
- *sslcert_country*: the content of the "countryName" field in generated
  certificates. Setting this field is mandatory.
- *sslcert_state*: the content of the "stateOrProvinceName" field in generated
  certificates.
- *sslcert_locality*: the content of the "localityName" field in generated
  certificates.
- *sslcert_organisation*:  the content of the "organizationName" field in
  generated certificates. Setting this field is mandatory.
- *sslcert_unit*: the content of the "organizationalUnitName" field in
  generated certificates.
- *sslcert_email*: the content of the "emailAddress" field in generated
  certificates.

Example usage:

  include apache_anf::ssl

*/
class apache_anf::ssl inherits apache_anf {
  case $operatingsystem {
    Debian,Ubuntu:  { include apache_anf::ssl::debian}
    RedHat,CentOS:  { include apache_anf::ssl::redhat}
    Solaris:        { include apache_anf::ssl::solaris}
    default: { fail "Unsupported operatingsystem ${operatingsystem}" }
  }
}
