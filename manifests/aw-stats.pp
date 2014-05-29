define apache_anf::aw-stats($ensure=present, $aliases=[]) {

  include apache_anf::params

  # used in ERB template
  $wwwroot = $apache_anf::params::sroot

  file { "${apache_anf::params::awstats_conf_dir}/awstats.${name}.conf":
    ensure  => $ensure,
    content => template("apache_anf/awstats.erb"),
    require => [Package["apache"], Class["apache_anf::awstats"]],
  }

  file { "${apache_anf::params::vroot}/${name}/conf/awstats.conf":
    ensure  => $ensure,
    owner   => root,
    group   => root,
    source  => $operatingsystem ? {
      /RedHat|CentOS/ => "puppet:///modules/${module_name}/awstats.rh.conf",
      /Debian|Ubuntu/ => "puppet:///modules/${module_name}/awstats.deb.conf",
      'Solaris'       => "puppet:///modules/${module_name}/awstats.solaris.conf",
    },
    seltype => $operatingsystem ? {
      "RedHat" => "httpd_config_t",
      "CentOS" => "httpd_config_t",
      default  => undef,
    },
    notify  => Exec["apache-graceful"],
    require => Apache_anf::Vhost[$name],
  }
}
