require 'spec_helper'

describe 'jenkins::augeas' do

  let(:title) { 'myplug' }
  let(:facts) {{ :osfamily => 'RedHat', :operatingsystem => 'CentOS' }}


  [false,'false'].each do |pval|
    describe "with plugin param #{pval} (#{pval.class})" do
      let (:params) {{ :config_filename => 'foo.xml', :changes => ['set foo bar'], :plugin => pval }}
      it do
        should contain_augeas('jenkins::augeas: myplug').with(
          :incl    => "/var/lib/jenkins/foo.xml",
          :context => "/files/var/lib/jenkins/foo.xml/",
          :changes => ['set foo bar'],
          :lens    => 'Xml.lns',
        )
        should_not contain_jenkins__plugin('myplug')
      end

    end
  end

  [true, 'true'].each do |pval|
    describe "with plugin param #{pval} (#{pval.class})" do
      let (:params) {{ :config_filename => 'foo.xml', :changes => ['set foo bar'], :plugin => pval }}
      it do
        should contain_augeas('jenkins::augeas: myplug').with(
          :incl    => "/var/lib/jenkins/foo.xml",
          :context => "/files/var/lib/jenkins/foo.xml/",
          :changes => ['set foo bar'],
          :lens    => 'Xml.lns',
        )
        should contain_jenkins__plugin('myplug')
      end
    end
  end

  describe "with plugin param 'pluginname'" do
    let (:params) {{ :config_filename => 'foo.xml', :changes => ['set foo bar'], :plugin => 'pluginname' }}
    it do
      should contain_augeas('jenkins::augeas: myplug').with(
        :incl    => "/var/lib/jenkins/foo.xml",
        :context => "/files/var/lib/jenkins/foo.xml/",
        :changes => ['set foo bar'],
        :lens    => 'Xml.lns',
      )
      should contain_jenkins__plugin('pluginname')
    end
  end

  describe "with plugin param wrong type" do
    let (:params) {{:config_filename => 'foo.xml', :changes => [], :plugin => ['foo','bar'] }}
    it do
      should raise_error(Puppet::Error, /is not a string/i)
    end
  end

  describe "with plugin_version set" do
    let (:params) {{
        :config_filename => 'foo.xml',
        :changes         => [],
        :plugin_version  => '0.1',
        :plugin          => true,
    }}
    it do
      should contain_jenkins__plugin('myplug').with(
        :version       => '0.1',
        :manage_config => false,
      )
    end
  end
  describe "with context set" do
    let (:params) {{
      :plugin          => false,
      :config_filename => 'foo.xml',
      :context         => 'foo/bar',
      :changes         => [],
    }}
    it do
      should contain_augeas('jenkins::augeas: myplug').with(
        :incl    => '/var/lib/jenkins/foo.xml',
        :context => '/files/var/lib/jenkins/foo.xml/foo/bar',
        :lens    => 'Xml.lns',
      )
    end
  end

  [ ['get foo != bar'], 'get foo != bar'].each do |pval|
    describe "with param onlyif set and class is #{pval.class}" do
      let (:params) {{
        :plugin          => false,
        :config_filename => 'foo.xml',
        :changes         => [ 'set foo bar' ],
        :onlyif          => pval,
      }}
      it do
        should contain_augeas('jenkins::augeas: myplug').with(
          :incl    => '/var/lib/jenkins/foo.xml',
          :context => '/files/var/lib/jenkins/foo.xml/',
          :changes => ['set foo bar'],
          :onlyif  => pval,
        )
      end
    end
  end

  describe "with param onlyif set and its a boolean" do
    let (:params) {{
      :plugin          => false,
      :config_filename => 'foo.xml',
      :changes         => ['set foo bar'],
      :onlyif          => false,
    }}
    it do
      should raise_error(Puppet::Error, /is not an array/i)
    end
  end

  [ ['set foo bar'], 'set foo bar'].each do |pval|
    describe "with param changes set and class is #{pval.class}" do
      let (:params) {{
        :plugin          => false,
        :config_filename => 'foo.xml',
        :changes         => pval,
      }}
      it do
        should contain_augeas('jenkins::augeas: myplug').with(
          :incl    => '/var/lib/jenkins/foo.xml',
          :context => '/files/var/lib/jenkins/foo.xml/',
          :changes => pval,
        )
      end
    end
  end

  describe "with param changes is a number" do
    let (:params) {{
      :plugin          => false,
      :config_filename => 'foo.xml',
      :changes         => 13,
    }}
    it do
      should raise_error(Puppet::Error, /is not an array/i)
    end
  end
end
