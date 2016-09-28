require 'spec_helper'

describe 'jenkins::augeas' do

  let(:title) { 'myplug' }
  let(:facts) do
    {
      :osfamily                  => 'RedHat',
      :operatingsystem           => 'CentOS',
      :operatingsystemrelease    => '6.7',
      :operatingsystemmajrelease => '6',
    }
  end


  #-------------------------------------------------------------------------------
  #      |              o
  # ,---.|    .   .,---..,---.    ,---.,---.,---.,---.,-.-.
  # |   ||    |   ||   |||   |    |   |,---||    ,---|| | |
  # |---'`---'`---'`---|``   '    |---'`---^`    `---^` ' '
  # |              `---'          |

  [false].each do |pval|
    describe "with plugin param #{pval} (#{pval.class})" do
      let (:params) {{ :config_filename => 'foo.xml', :changes => ['set foo bar'], :plugin => pval }}
      it do
        is_expected.to contain_augeas('jenkins::augeas: myplug').with(
          :incl    => '/var/lib/jenkins/foo.xml',
          :context => '/files/var/lib/jenkins/foo.xml/',
          :changes => ['set foo bar'],
          :lens    => 'Xml.lns',
        )
        is_expected.to_not contain_jenkins__plugin('myplug')
      end

    end
  end

  [true].each do |pval|
    describe "with plugin param #{pval} (#{pval.class})" do
      let (:params) {{ :config_filename => 'foo.xml', :changes => ['set foo bar'], :plugin => pval }}
      it do
        is_expected.to contain_jenkins__plugin('myplug')
      end
    end
  end

  describe "with plugin param 'pluginname'" do
    let (:params) {{ :config_filename => 'foo.xml', :changes => ['set foo bar'], :plugin => 'pluginname' }}
    it do
      is_expected.to contain_jenkins__plugin('pluginname')
    end
  end

  describe 'with plugin param wrong type' do
    let (:params) {{:config_filename => 'foo.xml', :changes => [], :plugin => ['foo','bar'] }}
    it do
      is_expected.to raise_error(Puppet::Error, /must be bool or string/i)
    end
  end


  #-------------------------------------------------------------------------------
  #      |              o                             o
  # ,---.|    .   .,---..,---.   .    ,,---.,---.,---..,---.,---.    ,---.,---.,---.,---.,-.-.
  # |   ||    |   ||   |||   |    \  / |---'|    `---.||   ||   |    |   |,---||    ,---|| | |
  # |---'`---'`---'`---|``   '     `'  `---'`    `---'``---'`   '    |---'`---^`    `---^` ' '
  # |              `---'      ---                                    |

  describe 'with plugin_version set' do
    let (:params) {{
        :config_filename => 'foo.xml',
        :changes         => [],
        :plugin_version  => '0.1',
        :plugin          => true,
    }}
    it do
      is_expected.to contain_jenkins__plugin('myplug').with(
        :version       => '0.1',
        :manage_config => false,
      )
    end
  end


  #-------------------------------------------------------------------------------
  #                |             |
  # ,---.,---.,---.|--- ,---..  ,|---     ,---.,---.,---.,---.,-.-.
  # |    |   ||   ||    |---' >< |        |   |,---||    ,---|| | |
  # `---'`---'`   '`---'`---''  ``---'    |---'`---^`    `---^` ' '
  #                                       |
  describe 'without context set' do
    let (:params) {{
      :plugin          => false,
      :config_filename => 'foo.xml',
      :changes         => [],
    }}
    it do
      is_expected.to contain_augeas('jenkins::augeas: myplug').with(
        :incl    => '/var/lib/jenkins/foo.xml',
        :context => '/files/var/lib/jenkins/foo.xml/',
        :lens    => 'Xml.lns',
      )
    end
  end

  describe 'with context set' do
    let (:params) {{
      :plugin          => false,
      :config_filename => 'foo.xml',
      :context         => '/foo/bar',
      :changes         => [],
    }}
    it do
      is_expected.to contain_augeas('jenkins::augeas: myplug').with(
        :incl    => '/var/lib/jenkins/foo.xml',
        :context => '/files/var/lib/jenkins/foo.xml/foo/bar',
        :lens    => 'Xml.lns',
      )
    end
  end


  #-------------------------------------------------------------------------------
  #           |         o,---.
  # ,---.,---.|    ,   ..|__.     ,---.,---.,---.,---.,-.-.
  # |   ||   ||    |   |||        |   |,---||    ,---|| | |
  # `---'`   '`---'`---|``        |---'`---^`    `---^` ' '
  #                `---'          |

  [ ['get foo != bar'], 'get foo != bar'].each do |pval|
    describe "with param onlyif set and class is #{pval.class}" do
      let (:params) {{
        :plugin          => false,
        :config_filename => 'foo.xml',
        :changes         => [ 'set foo bar' ],
        :onlyif          => pval,
      }}
      it do
        is_expected.to contain_augeas('jenkins::augeas: myplug').with(
          :incl    => '/var/lib/jenkins/foo.xml',
          :context => '/files/var/lib/jenkins/foo.xml/',
          :changes => ['set foo bar'],
          :onlyif  => pval,
        )
      end
    end
  end

  describe 'with param onlyif set and its a boolean' do
    let (:params) {{
      :plugin          => false,
      :config_filename => 'foo.xml',
      :changes         => ['set foo bar'],
      :onlyif          => false,
    }}
    it do
      is_expected.to raise_error(Puppet::Error, /must be string or array/i)
    end
  end

  #-------------------------------------------------------------------------------
  #      |
  # ,---.|---.,---.,---.,---.,---.,---.    ,---.,---.,---.,---.,-.-.
  # |    |   |,---||   ||   ||---'`---.    |   |,---||    ,---|| | |
  # `---'`   '`---^`   '`---|`---'`---'    |---'`---^`    `---^` ' '
  #                     `---'              |
  [ ['set foo bar'], 'set foo bar'].each do |pval|
    describe "with param changes set and class is #{pval.class}" do
      let (:params) {{
        :plugin          => false,
        :config_filename => 'foo.xml',
        :changes         => pval,
      }}
      it do
        is_expected.to contain_augeas('jenkins::augeas: myplug').with(
          :incl    => '/var/lib/jenkins/foo.xml',
          :changes => pval,
        )
      end
    end
  end

  describe 'with param changes is a number' do
    let (:params) {{
      :plugin          => false,
      :config_filename => 'foo.xml',
      :changes         => 13,
    }}
    it { is_expected.to raise_error(Puppet::Error, /must be string or array/i) }
  end


  #-------------------------------------------------------------------------------
  #                |              |
  # ,---.,---.,---.|--- ,---.,---.|---     ,---.,---.,---.,---.,-.-.
  # |    |---'`---.|    ,---||    |        |   |,---||    ,---|| | |
  # `    `---'`---'`---'`---^`    `---'    |---'`---^`    `---^` ' '
  #                                        |
  {
    true    => 'safe-restart-jenkins',
    false   => 'reload-jenkins',
  }.each do |pval,expected|
    describe "with param restart set to '#{pval}' (#{pval.class})" do
      let (:params) {{
        :plugin          => false,
        :config_filename => 'foo.xml',
        :changes         => [],
        :restart         => pval,
      }}
      it { is_expected.to contain_augeas('jenkins::augeas: myplug').that_notifies("Exec[#{expected}]") }
    end
  end

  describe 'with param restart set to an invalid value' do
    let (:params) {{
        :plugin => false,
        :config_filename => 'foo.xml',
        :changes => [],
        :restart => 'not-a-boolean-thats-sure',
    }}
    it { is_expected.to raise_error(Puppet::Error, /is not a boolean/i) }
  end

end
