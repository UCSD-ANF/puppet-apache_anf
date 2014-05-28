class apache_anf::params {

  $supported_os = ['RedHat','CentOS','Debian','Ubuntu','Solaris']

  if ! ( $::operatingsystem in $supported_os ) {
    fail("unsupported operatingsystem \"$::operatingsystem\"")
  }

  $pkg = $::operatingsystem ? {
    /RedHat|CentOS/ => 'httpd',
    /Debian|Ubuntu/ => 'apache2',
    'Solaris'       => 'apache2',
  }

  $service = $::operatingsystem ? {
    /RedHat|CentOS/ => 'httpd',
    /Debian|Ubuntu/ => 'apache2',
    'Solaris'       => 'cswapache2:default',
  }

  # ServerRoot
  $sroot = $::operatingsystem ? {
    /RedHat|CentOS/ => '/etc/httpd',
    /Debian|Ubuntu/ => '/etc/apache2',
    'Solaris'       => '/opt/csw/apache2',
  }

  # Base Directory for vhosts
  $vroot = $::apache_root ? {
    "" => $::operatingsystem ? {
      /RedHat|CentOS/ => '/var/www/vhosts',
      /Debian|Ubuntu/ => '/var/www',
      Solaris         => '/opt/csw/apache2/share/vhosts',
    },
    default => $::apache_root
  }

  $default_vhost_dir = $::operatingsystem ? {
    /RedHat|CentOS/ => '/var/www/html',
    /Debian|Ubuntu/ => '/var/www/html',
    Solaris         => '/opt/csw/apache2/share/htdocs',
  }

  # Location of error dir includes
  $error = $::operatingsystem ? {
    /RedHat|CentOS/ => '/var/www/error',
    /Debian|Ubuntu/ => '/var/www/error',
    'Solaris'       => '/opt/csw/apache2/share/error',
  }

  # Location of FancyIndexing Icons
  $icons = $::operatingsystem ? {
    Solaris => '/opt/csw/apache2/share/icons',
    default => '/var/www/icons',
  }

  # Location of default cgi-bin directory
  $cgibindir = $::operatingsystem ? {
    Solaris => '/opt/csw/apache2/share/cgi-bin',
    default => '/var/www/cgi-bin',
  }

  $user = $::operatingsystem ? {
    /RedHat|CentOS/ => 'apache',
    /Debian|Ubuntu/ => 'www-data',
    Solaris         => 'webservd',
  }

  $group = $::operatingsystem ? {
    /RedHat|CentOS/ => 'apache',
    /Debian|Ubuntu/ => 'www-data',
    Solaris         => 'webservd',
  }

  $conf = $::operatingsystem ? {
    /RedHat|CentOS/ => '/etc/httpd',
    /Debian|Ubuntu/ => '/etc/apache2',
    Solaris         => '/opt/csw/apache2/etc',
  }

  # Location of additional conf files relative to sroot
  # Trailing slash is intentional
  $confrel = $::operatingsystem ? {
    /RedHat|CentOS/ => '',
    /Debian|Ubuntu/ => '',
    Solaris         => 'etc/',
  }

  $log = $::operatingsystem ? {
    /RedHat|CentOS/ => '/var/log/httpd',
    /Debian|Ubuntu/ => '/var/log/apache2',
    Solaris         => '/opt/csw/apache2/var/log',
  }

  # Location of log files relative to sroot
  # Trailing slash is intentional
  $logsrel = $::operatingsystem ? {
    /RedHat|CentOS/ => 'logs/',
    /Debian|Ubuntu/ => 'logs/',
    Solaris         => 'var/log/',
  }

  $access_log = $::operatingsystem ? {
    /RedHat|CentOS/ => "${log}/access_log",
    /Debian|Ubuntu/ => "${log}/access.log",
    Solaris         => "${log}/access.log",
  }

  $a2ensite = $::operatingsystem ? {
    /RedHat|CentOS/ => '/usr/local/sbin/a2ensite',
    /Debian|Ubuntu/ => '/usr/sbin/a2ensite',
    Solaris         => '/usr/local/sbin/a2ensite',
  }

  $error_log = $::operatingsystem ? {
    /RedHat|CentOS/ => "${log}/error_log",
    /Debian|Ubuntu/ => "${log}/error.log",
    Solaris         => "${log}/error.log",
  }

  $awstats_conf_dir = $::operatingsystem ? {
    /Debian|Ubuntu/ => '/etc/awstats',
    /RedHat|CentOS/ => '/etc/awstats',
    'Solaris'       => '/opt/csw/etc/awstats',
  }

  $mime_file = $::operatingsystem ? {
    /Debian|Ubuntu/ => '/etc/mime.types',
    /RedHat|CentOS/ => '/etc/mime.types',
    'Solaris'       => 'etc/mime.types',
  }


}
