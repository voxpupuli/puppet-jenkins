require 'spec_helper'

describe 'jenkins::config' do

  # Ensure compilation
  it { should create_class('jenkins::config') }

end
