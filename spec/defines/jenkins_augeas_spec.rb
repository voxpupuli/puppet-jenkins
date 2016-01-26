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
  describe "with onlyif set" do
    let (:params) {{
      :plugin          => false,
      :config_filename => 'foo.xml',
      :changes         => [ 'set foo bar' ],
      :onlyif          => [ 'get foo != bar' ],
    }}
    it do
      should contain_augeas('jenkins::augeas: myplug').with(
        :incl    => '/var/lib/jenkins/foo.xml',
        :context => '/files/var/lib/jenkins/foo.xml/',
        :changes => ['set foo bar'],
        :onlyif  => ['get foo != bar'],
      )
    end
  end

end
