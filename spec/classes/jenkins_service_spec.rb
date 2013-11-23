require 'spec_helper'

describe 'jenkins::service' do

  it { should contain_service('jenkins') }

end
