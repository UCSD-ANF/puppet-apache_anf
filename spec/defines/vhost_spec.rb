require 'spec_helper'

describe 'apache::vhost' do
  let(:title) { 'foo.example.com' }
  let(:preconditions) do
    "include apache"
  end

  context 'on an unsupported os' do
    let(:facts) do
      {
        :osfamily        => 'Darwin',
        :operatingsystem => 'Darwin',
      }
    end

    it 'should fail to compile' do
      expect {
        should include_class('apache::params')
      }.to raise_error(Puppet::Error, /unsupported operatingsystem/)
    end

  end

  describe 'with osfamily specific defaults' do
    {
      'Solaris'   => {
        :wwwuser  => 'webservd',
        :wwwgroup => 'webservd',
        :wwwroot  => '/opt/csw/apache2/share/vhosts',
        :conf     => '/opt/csw/apache2/etc',
        :confrel  => 'etc/',
      },
      'Debian'    => {
        :wwwuser  => 'www-data',
        :wwwgroup => 'www-data',
        :wwwroot  => '/var/www',
        :conf     => '/etc/apache2',
        :confrel  => '',
      },
      'RedHat'    => {
        :wwwuser  => 'apache',
        :wwwgroup => 'apache',
        :wwwroot  => '/var/www/vhosts',
        :conf     => '/etc/httpd',
        :confrel  => '',
      },
    }.each do |osfamily, osdefaults|

      describe "when osfamily is #{osfamily}" do
        let(:facts) do
          {
            :osfamily        => osfamily,
            :operatingsystem => osfamily,
          }
        end

        it { should include_class('apache::params') }

        context 'with ensure => present' do
          let :params do
            {:ensure => 'present'}
          end

          context 'and cgibin => true' do
            let :params do
              {:cgibin => true}
            end

            it do
              should contain_file(
                "#{osdefaults[:conf]}/sites-available/foo.example.com"
              ).with_content(
                /  ScriptAlias \/cgi-bin\/ #{osdefaults[:wwwroot]}\/foo\.example\.com\/cgi-bin\//
              )
            end

          end

          context 'and cgibin => /test/cgibindir without trailing slash' do
            let :params do
              {:cgibin => '/test/cgibindir'}
            end

            it do
              should contain_file(
                "#{osdefaults[:conf]}/sites-available/foo.example.com"
              ).with_content(
                /  ScriptAlias \/cgi-bin\/ \/test\/cgibindir\/$/
              )
            end
          end
          context 'and cgibin => /test/cgibindir/ with trailing slash' do
            let :params do
              {:cgibin => '/test/cgibindir/'}
            end

            it do
              should contain_file(
                "#{osdefaults[:conf]}/sites-available/foo.example.com"
              ).with_content(
                /  ScriptAlias \/cgi-bin\/ \/test\/cgibindir\/$/
              )
            end
          end
        end

        context 'with ensure => absent' do
          let :params do
            {:ensure => 'absent'}
          end
        end

        context 'with ensure => disabled' do
          let :params do
            {:ensure => 'disabled'}
          end
        end

      end

    end

  end

end
