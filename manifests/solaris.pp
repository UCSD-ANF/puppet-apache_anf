class apache::solaris inherits apache::base {

  include apache::params

  # BEGIN inheritance from apache::base
  Exec['apache-graceful'] {
    command => '/opt/csw/apache2/sbin/apachectl graceful',
    onlyif  => '/opt/csw/apache2/sbin/apachectl configtest',
  }

  Package['apache'] {
    require => [
      File ['/usr/local/sbin/a2ensite'],
      File ['/usr/local/sbin/a2dissite'],
      File ['/usr/local/sbin/a2enmod'],
      File ['/usr/local/sbin/a2dismod'],
    ],
  }

  # $httpd_pid_file is used in template logrotate-httpd.erb
  $httpd_pid_file = '/var/run/httpd.pid'
  File['logrotate configuration'] {
    path    => '/etc/logrotate.d/httpd',
    content => template('apache/logrotate-httpd.erb'),
  }

  File['default status module configuration'] {
    path   => "${apache::params::conf}/conf.d/status.conf",
    source => "puppet:///modules/${module_name}/etc/httpd/conf/status.conf",
  }

  # END inheritance from apache::base

  file { $default_vhost_dir:
    ensure  => 'directory',
    require => Package['apache'],
    owner   => 'root',
    group   => 'bin',
  }

  file { ["/usr/local/sbin/a2ensite", "/usr/local/sbin/a2dissite", "/usr/local/sbin/a2enmod", "/usr/local/sbin/a2dismod"]:
    ensure => present,
    mode => 755,
    owner => "root",
    group => "root",
    source => "puppet:///modules/${module_name}/usr/local/sbin/a2X.solaris",
  }

  $httpd_mpm = $apache_mpm_type ? {
    ''         => 'httpd', # default MPM
    'pre-fork' => 'httpd',
    'prefork'  => 'httpd',
    default    => "httpd.${apache_mpm_type}",
  }

  augeas { "select httpd mpm ${httpd_mpm}":
    changes => "set /files/etc/sysconfig/httpd/HTTPD /usr/sbin/${httpd_mpm}",
    require => Package["apache"],
    notify  => Service["apache"],
  }

  file { [
      "${apache::params::conf}/sites-available",
      "${apache::params::conf}/sites-enabled",
      "${apache::params::conf}/mods-enabled"
    ]:
    ensure => directory,
    mode => 644,
    owner => "root",
    group => "bin",
    require => Package["apache"],
  }

  file { "${apache::params::conf}/conf/httpd.conf":
    ensure => present,
    content => template("apache/httpd.conf.erb"),
    notify  => Service["apache"],
    require => Package["apache"],
  }

  # the following command was used to generate the content of the directory:
  # egrep '(^|#)LoadModule' /opt/csw/apache2/etc/httpd.conf.CSW | gsed -r 's|#?(.+ (.+)_module .+)|echo "\1" > mods-available/solaris/\2.load|' | sh
  # ssl.load was then changed to a template (see apache-ssl-redhat.pp)
  file { "${apache::params::conf}/mods-available":
    ensure => directory,
    source => "puppet:///modules/${module_name}/etc/httpd/mods-available/solaris/",
    recurse => true,
    mode => 644,
    owner => "root",
    group => "bin",
    require => Package["apache"],
  }


}
