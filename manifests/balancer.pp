/*

== Definition: apache_anf::balancer

Define a basic balanced proxy, to split requests between different backends,
with an optional hot standby server.

This definition will ensure all the required modules are loaded and will
drop a configuration snippet in the virtualhost's conf/ directory.

Parameters:
- *ensure*: present/absent.
- *location*: path to balance between backends.
- *proto*: protocol used to communicate with the backends. "http" or "ajp" are
  the usual suspects. "http" is the default.
- *members*: array of "hostname:port" pairs for each registered backend.
- *standbyurl*: optional URL of the sorryserver (requests will get directed to
  this address when all backends are dead).
- *params*: array of parameters to pass to every backend. See: http://httpd.apache.org/docs/2.2/mod/mod_proxy.html#proxypass
  Defaults to "retry=5"
- *vhost*: the virtualhost to which this directive will apply. Mandatory
  parameter.
- *filename*: basename of the file in which the directive(s) will be put.
  Useful in the case directive order matters: apache reads the files in conf/
  in alphabetical order.

Requires:
- Class["apache"]
- matching Apache_anf::Vhost[] instance

Example usage:

  apache_anf::balancer { "my balanced service":
    location   => "/mywebapp/",
    proto      => "ajp",
    members    => [
      "node1.cluster:8009",
      "node2.cluster:8009",
      "node3.cluster:8009"
    ],
    params     => ["retry=20", "min=3", "flushpackets=auto"],
    standbyurl => "http://sorryserver.cluster/",
    vhost      => "www.example.com",
  }

*/
define apache_anf::balancer (
  $ensure="present",
  $location="",
  $proto="http",
  $members=[],
  $standbyurl="",
  $params=["retry=5"],
  $filename="",
  $vhost
) {

  # normalise name
  $fname = regsubst($name, "\s", "_", "G")

  include apache_anf::params

  $balancer = "balancer://${fname}"

  if !defined(Apache_anf::Module["proxy"]) {
    apache_anf::module {"proxy": }
  }

  if !defined(Apache_anf::Module["proxy_balancer"]) {
    apache_anf::module {"proxy_balancer": }
  }

  # ensure proxy modules are enabled
  case $proto {
    http: {
      if !defined(Apache_anf::Module["proxy_http"]) {
        apache_anf::module {"proxy_http": }
      }
    }

    ajp: {
      if !defined(Apache_anf::Module["proxy_ajp"]) {
        apache_anf::module {"proxy_ajp": }
      }
    }
  }

  file{ "${name} balancer on ${vhost}":
    ensure  => $ensure,
    content => template("apache_anf/balancer.erb"),
    seltype => $operatingsystem ? {
      "RedHat" => "httpd_config_t",
      "CentOS" => "httpd_config_t",
      default  => undef,
    },
    name    => $filename ? {
      ""      => "${apache_anf::params::vroot}/${vhost}/conf/balancer-${fname}.conf",
      default => "${apache_anf::params::vroot}/${vhost}/conf/${filename}",
    },
    notify  => Exec["apache-graceful"],
    require => Apache_anf::Vhost[$vhost],
  }

}
