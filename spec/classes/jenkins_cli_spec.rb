require 'spec_helper'

describe 'jenkins::cli' do

      it { should create_class('jenkins::cli') }
      it { should contain_exec('jenkins-cli') }

end
