class apache_anf::deflate {

  include apache_anf::params

  apache_anf::module {"deflate":
    ensure => present,
  }

  file { "deflate.conf":
    ensure => present,
    path => "${apache_anf::params::conf}/conf.d/deflate.conf",
    content => "# file managed by puppet
<IfModule mod_deflate.c>
  AddOutputFilterByType DEFLATE application/x-javascript application/javascript text/css text/html text/plain application/json
  BrowserMatch Safari/4 no-gzip
</IfModule>
",
    notify  => Exec["apache-graceful"],
    require => Package["apache"],
  }

}
