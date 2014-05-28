require 'spec_helper'

describe 'apache_anf::solaris' do

  let(:facts) do
    {
      :osfamily        => 'Solaris',
      :operatingsystem => 'Solaris',
      :concat_basedir  => '/tmp/concatbasedir',
    }
  end

  it do
    should contain_class('apache_anf::params')

    should contain_exec('apache-graceful').with(
      :command => '/usr/sbin/svcadm refresh cswapache2:default',
      :onlyif  => '/opt/csw/apache2/sbin/apachectl configtest'
    )

    should contain_package('apache2_utils').with_provider('pkgutil')

    should contain_file('logrotate configuration').with(
      :path    => '/etc/logrotate.d/httpd',
      :content => /\/var\/run\/httpd.pid/
    )

    should contain_file('/opt/csw/apache2/etc/conf.d').with(
      :ensure => 'directory',
      :owner  => 'root',
      :group  => 'bin',
      :mode   => '0755'
    )

    should contain_file('default status module configuration').with(
      :path => '/opt/csw/apache2/etc/conf.d/status.conf'
    )


    should contain_file('/opt/csw/apache2/share/htdocs').with(
      :ensure => 'directory',
      :owner  => 'root',
      :group  => 'bin'
    )

    end

  it 'should have an httpd.conf template with the correct contents' do
    content = param_value( subject, 'file',
                          '/opt/csw/apache2/etc/httpd.conf',
                          'content')
    expected_lines = [
      'ServerRoot /opt/csw/apache2',
      'PidFile /var/run/httpd.pid',
      'Include etc/ports.conf',
      'Include etc/mods-enabled/',
      'Include etc/conf.d/*.conf',
      'User webservd',
      'Group webservd',
      'TypesConfig etc/mime.types',
      'ErrorLog var/log/error_log',
      'CustomLog var/log/access_log common',
      'CustomLog var/log/access_log combined',
      'Alias /icons/ "/opt/csw/apache2/share/icons/"',
      '<Directory "/opt/csw/apache2/share/icons">',
      '<Directory "/opt/csw/apache2/share/cgi-bin">',
    ]
    (content.split("\n") & expected_lines).should == expected_lines
  end

  context 'with default mpm' do
    it { should contain_exec('select httpd mpm httpd.prefork') }
  end

  context 'with apache_mpm_type = pre-fork' do
    let(:pre_condition) do
      "$apache_mpm_type='pre-fork'"
    end
    it { should contain_exec('select httpd mpm httpd.prefork') }
  end

  context 'with apache_mpm_type = prefork' do
    let(:pre_condition) do
      "$apache_mpm_type='prefork'"
    end
    it { should contain_exec('select httpd mpm httpd.prefork') }
  end

  context 'with apache_mpm_type = worker' do
    let(:pre_condition) do
      "$apache_mpm_type='worker'"
    end
    it { should contain_exec('select httpd mpm httpd.worker') }
  end

  context 'with apache_mpm_type = garbage' do
    let(:pre_condition) do
      "$apache_mpm_type='worker'"
    end
    it { should contain_exec('select httpd mpm httpd.worker') }
  end

end
