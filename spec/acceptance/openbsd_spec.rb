require 'spec_helper_acceptance'

describe 'jenkins class on OpenBSD', :if => fact('osfamily') == 'OpenBSD' do

  before(:all) do
    pkg_conf_pp = <<-EOS
    $source = "http://ftp.openbsd.org/pub/OpenBSD/${::kernelmajversion}/packages/${::hardwareisa}/"

    file { '/etc/pkg.conf':
      ensure  => file,
      owner   => 'root',
      group   => 'wheel',
      mode    => '0644',
      content => "# OpenBSD pkg.conf\ninstallpath=${source}\n",
    }
  EOS

    apply_manifest(pkg_conf_pp, :catch_failures => true)
  end

  context 'default parameters' do
    it 'should work with no errors' do
      pp = <<-EOS
      class {'jenkins':}
      EOS

      # Run it twice and test for idempotency
      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes => true)
    end

    describe port(8000) do
      it {
        sleep(10) # Jenkins takes a while to start up
        should be_listening
      }
    end

    describe service('jenkins') do
      it { should be_running }
    end

  end
end
