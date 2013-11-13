require 'spec_helper'

describe 'jenkins::proxy' do

  it { should create_class('jenkins::proxy') }
  it { should contain_file('/var/lib/jenkins/proxy.xml') }

end
