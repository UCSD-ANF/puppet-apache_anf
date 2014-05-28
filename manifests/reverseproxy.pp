class apache_anf::reverseproxy {

  include apache_anf::params

  apache_anf::module {["proxy", "proxy_http", "proxy_ajp", "proxy_connect"]: }

  file { "reverseproxy.conf":
    ensure  => "present",
    path    => "${apache_anf::params::conf}/conf.d/reverseproxy.conf",
    content => "# file managed by puppet
<IfModule mod_proxy.c>
  ProxyRequests Off
  <Proxy *>
    Order Deny,Allow
    Deny from all
  </Proxy>
</IfModule>
",
    notify  => Exec["apache-graceful"],
    require => Package["apache"],
  }

}
