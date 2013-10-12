require 'spec_helper'

describe 'jenkins::sysconfig' do
  let(:title) { 'myprop' }
  let(:facts) { { :osfamily => 'RedHat' } }
  let(:params) { { 'value' => 'myvalue' } }

  it { should contain_file_line('Jenkins sysconfig setting myprop') }

end
