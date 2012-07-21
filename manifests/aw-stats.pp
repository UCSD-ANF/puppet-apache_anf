define apache::aw-stats($ensure=present, $aliases=[]) {

  include apache::params

  # used in ERB template
  $wwwroot = $apache::params::sroot

  file { "${apache::params::awstats_conf_dir}/awstats.${name}.conf":
    ensure  => $ensure,
    content => template("apache/awstats.erb"),
    require => [Package["apache"], Class["apache::awstats"]],
  }

  file { "${apache::params::vroot}/${name}/conf/awstats.conf":
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
    require => Apache::Vhost[$name],
  }
}
