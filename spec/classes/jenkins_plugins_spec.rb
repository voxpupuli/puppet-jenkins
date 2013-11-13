require 'spec_helper'

describe 'jenkins::plugins' do

  # Ensure compilation
  it { should create_class('jenkins::plugins') }

end
