class apache_anf::solaris inherits apache_anf::base {

  include apache_anf::params

  # BEGIN inheritance from apache_anf::base
  Exec['apache-graceful'] {
    command => "/usr/sbin/svcadm refresh ${apache_anf::params::service}",
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

  File['log directory'] {
    group   => 'bin',
    require => Package['apache'],
  }

  # Need this for htpasswd and friends
  package{'apache2_utils' :
    ensure   => installed,
    provider => 'pkgutil',
  }

  # $httpd_pid_file is used in template logrotate-httpd.erb
  # and in httpd.conf.erb
  $httpd_pid_file = '/var/run/httpd.pid'

  File['logrotate configuration'] {
    path    => '/etc/logrotate.d/httpd',
    content => template('apache_anf/logrotate-httpd.erb'),
  }

  file { "${apache_anf::params::conf}/conf.d":
    ensure  => directory,
    owner   => 'root',
    group   => 'bin',
    mode    => '0755',
    require => Package['apache'],
  }

  File['default status module configuration'] {
    path    => "${apache_anf::params::conf}/conf.d/status.conf",
    source  => "puppet:///modules/${module_name}/etc/httpd/conf/status.conf",
    require => File["${apache_anf::params::conf}/conf.d"],
  }

  # END inheritance from apache_anf::base

  file { $apache_anf::params::default_vhost_dir:
    ensure  => 'directory',
    owner   => 'root',
    group   => 'bin',
    require => Package['apache'],
  }

  file { [
    "/usr/local/sbin/a2ensite",
    "/usr/local/sbin/a2dissite",
    "/usr/local/sbin/a2enmod",
    "/usr/local/sbin/a2dismod",
  ]:
    ensure => present,
    mode => 755,
    owner => "root",
    group => "root",
    source => "puppet:///modules/${module_name}/usr/local/sbin/a2X.solaris",
  }

  $httpd_mpm = $apache_mpm_type ? {
    ''         => 'httpd.prefork', # default MPM
    'pre-fork' => 'httpd.prefork',
    'prefork'  => 'httpd.prefork',
    default    => "httpd.${apache_mpm_type}",
  }

  exec { "select httpd mpm ${httpd_mpm}":
    command => "/opt/csw/sbin/alternatives --set httpd /opt/csw/apache2/sbin/${httpd_mpm}",
    unless  => "/bin/ls -l /opt/csw/apache2/sbin/httpd | /bin/sed 's/.*->\\ //g' | /bin/grep ${httpd_mpm}",
    require => Package["apache"],
    notify  => Service["apache"],
  }

  file { [
      "${apache_anf::params::conf}/sites-available",
      "${apache_anf::params::conf}/sites-enabled",
      "${apache_anf::params::conf}/mods-enabled"
    ]:
    ensure => directory,
    mode => 644,
    owner => "root",
    group => "bin",
    require => Package["apache"],
  }

  file { "${apache_anf::params::conf}/httpd.conf":
    ensure => present,
    content => template("apache_anf/httpd.conf.erb"),
    notify  => Service["apache"],
    require => Package["apache"],
  }

  # the following command was used to generate the content of the directory:
  # egrep '(^|#)LoadModule' /opt/csw/apache2/etc/httpd.conf.CSW | gsed -r 's|#?(.+ (.+)_module .+)|echo "\1" > mods-available/solaris/\2.load|' | sh
  # ssl.load was then changed to a template (see apache-ssl-redhat.pp)
  file { "${apache_anf::params::conf}/mods-available":
    ensure => directory,
    source => "puppet:///modules/${module_name}/etc/httpd/mods-available/solaris/",
    recurse => true,
    mode => 644,
    owner => "root",
    group => "bin",
    require => Package["apache"],
  }

  # this module is statically compiled on debian and must be enabled here
  apache_anf::module {["log_config"]:
    ensure => present,
    notify => Exec["apache-graceful"],
  }

}
