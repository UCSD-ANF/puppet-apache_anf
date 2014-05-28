require 'spec_helper'

describe 'apache_anf::dev', :type=>'class' do
  context 'on a Solaris OS' do
    let(:facts) {{
      :osfamily => 'Solaris',
      :operatingsystem => 'Solaris',
    }}

    it { should contain_package('apache-devel').with({
      :name => 'apache2_dev',
      :require => /Package\[gcc4\]/,
    }) }
  end

  context 'on a RedHat OS' do
    let(:facts) {{
      :osfamily => 'RedHat',
      :operatingsystem => 'CentOS',
    }}

    it { should contain_package('apache-devel').with({
      :name => 'httpd-devel',
      :require => /Package\[gcc\]/,
    }) }
  end

  context 'on a Debian OS' do
    let(:facts) {{
      :osfamily => 'Debian',
      :operatingsystem => 'Ubuntu',
    }}

    it { should_not contain_package('apache-devel') }
  end


end
