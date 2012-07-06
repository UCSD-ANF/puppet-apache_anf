class apache::params {

  $pkg = $operatingsystem ? {
    /RedHat|CentOS/ => 'httpd',
    /Debian|Ubuntu/ => 'apache2',
    'Solaris'       => 'apache2',
  }

  $service = $::operatingsystem ? {
    /RedHat|CentOS/ => 'httpd',
    /Debian|Ubuntu/ => 'apache2',
    'Solaris'       => 'cswapache2:default',
  }

  $root = $apache_root ? {
    "" => $operatingsystem ? {
      /RedHat|CentOS/ => '/var/www/vhosts',
      /Debian|Ubuntu/ => '/var/www',
      Solaris         => '/opt/csw/apache2/share/vhosts',
    },
    default => $apache_root
  }

  $default_vhost_dir = $::apache_default_vhost_dir ? {
    "" => $::operatingsystem ? {
      /RedHat|CentOS/ => '/var/www',
      /Debian|Ubuntu/ => '/var/www',
      Solaris         => '/opt/csw/apache2/share/htdocs',
    },
    default => $::apache_default_vhost_dir,
  }

  $user = $operatingsystem ? {
    /RedHat|CentOS/ => 'apache',
    /Debian|Ubuntu/ => 'www-data',
    Solaris         => 'webservd',
  }

  $group = $operatingsystem ? {
    /RedHat|CentOS/ => 'apache',
    /Debian|Ubuntu/ => 'www-data',
    Solaris         => 'webservd',
  }

  $conf = $operatingsystem ? {
    /RedHat|CentOS/ => '/etc/httpd',
    /Debian|Ubuntu/ => '/etc/apache2',
    Solaris         => '/opt/csw/apache2/etc',
  }

  $log = $operatingsystem ? {
    /RedHat|CentOS/ => '/var/log/httpd',
    /Debian|Ubuntu/ => '/var/log/apache2',
    Solaris         => '/opt/csw/apache2/var/log',
  }

  $access_log = $operatingsystem ? {
    /RedHat|CentOS/ => "${log}/access_log",
    /Debian|Ubuntu/ => "${log}/access.log",
    Solaris         => "${log}/access.log",
  }

  $a2ensite = $operatingsystem ? {
    /RedHat|CentOS/ => '/usr/local/sbin/a2ensite',
    /Debian|Ubuntu/ => '/usr/sbin/a2ensite',
    Solaris         => '/usr/local/sbin/a2ensite',
  }




  $error_log = $operatingsystem ? {
    /RedHat|CentOS/ => "${log}/error_log",
    /Debian|Ubuntu/ => "${log}/error.log",
  }

  $awstats_conf_dir => $::operatingsystem ? {
    /Debian,Ubuntu/ => '/etc/awstats',
    /RedHat,CentOS/ => '/etc/awstats',
    'Solaris'       => '/opt/csw/etc/awstats',
  }

}
