require 'spec_helper'

# Skip this example block under puppet-4 as it will fail with rspec-puppet
# 2.1.0.
#
# https://github.com/rodjek/rspec-puppet/issues/282
describe 'jenkins_port', :if => Puppet.version.to_f < 4.0 do

  let(:facts) { { :osfamily => 'RedHat', :operatingsystem => 'RedHat' } }
  let(:pre_condition) { 'include ::jenkins' }
  # Lazily loaded function call to be used in examples. Not overwriting
  # `subject` since rspec-puppet is already defining that to return the
  # function
  let(:port) {
    subject.call([])
  }

  it 'should default to 8080' do
    expect(port).to eql '8080'
  end

  context 'with overwritten configuration' do
    let(:pre_condition) do
      <<-ENDPUPPET
      class { 'jenkins':
        config_hash => {'HTTP_PORT' => {'value' => '1337'}},
      }
      ENDPUPPET
    end

    it 'should be our overwritten port' do
      expect(port).to eql('1337')
    end
  end
end
