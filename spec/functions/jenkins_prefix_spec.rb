require 'spec_helper'

# Skip this example block under puppet-4 as it will fail with rspec-puppet
# 2.1.0.
#
# https://github.com/rodjek/rspec-puppet/issues/282
describe 'jenkins_prefix', if: Puppet.version.to_f < 4.0 do
  let(:facts) { { osfamily: 'RedHat', operatingsystem: 'RedHat' } }
  let(:pre_condition) { 'include ::jenkins' }
  # Lazily loaded function call to be used in examples. Not overwriting
  # `subject` since rspec-puppet is already defining that to return the
  # function
  let(:prefix) do
    subject.call([])
  end

  it 'defaults to ""' do
    expect(prefix).to eql ''
  end

  context 'with overwritten configuration' do
    let(:pre_condition) do
      <<-ENDPUPPET
      class { 'jenkins':
        config_hash => {'PREFIX' => {'value' => '/test'}},
      }
      ENDPUPPET
    end

    it 'is our overwritten prefix' do
      expect(prefix).to eql('/test')
    end
  end
end
