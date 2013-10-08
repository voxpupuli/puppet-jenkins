require 'spec_helper'

describe 'jenkins::package' do

  it { should contain_package('jenkins') }

end
