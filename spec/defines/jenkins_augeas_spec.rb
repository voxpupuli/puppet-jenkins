require 'spec_helper'

describe 'jenkins::augeas' do
  let(:title) { 'myplug' }
  let(:facts) do
    {
      osfamily: 'RedHat',
      operatingsystem: 'CentOS',
      operatingsystemrelease: '6.7',
      operatingsystemmajrelease: '6'
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
      let(:params) { { config_filename: 'foo.xml', changes: ['set foo bar'], plugin: pval } }

      it do
        is_expected.to contain_augeas('jenkins::augeas: myplug').with(
          incl: '/var/lib/jenkins/foo.xml',
          context: '/files/var/lib/jenkins/foo.xml/',
          changes: ['set foo bar'],
          lens: 'Xml.lns'
        )
        is_expected.not_to contain_jenkins__plugin('myplug')
      end
    end
  end

  [true].each do |pval|
    describe "with plugin param #{pval} (#{pval.class})" do
      let(:params) { { config_filename: 'foo.xml', changes: ['set foo bar'], plugin: pval } }

      it do
        is_expected.to contain_jenkins__plugin('myplug')
      end
    end
  end

  describe "with plugin param 'pluginname'" do
    let(:params) { { config_filename: 'foo.xml', changes: ['set foo bar'], plugin: 'pluginname' } }

    it do
      is_expected.to contain_jenkins__plugin('pluginname')
    end
  end

  #-------------------------------------------------------------------------------
  #      |              o                             o
  # ,---.|    .   .,---..,---.   .    ,,---.,---.,---..,---.,---.    ,---.,---.,---.,---.,-.-.
  # |   ||    |   ||   |||   |    \  / |---'|    `---.||   ||   |    |   |,---||    ,---|| | |
  # |---'`---'`---'`---|``   '     `'  `---'`    `---'``---'`   '    |---'`---^`    `---^` ' '
  # |              `---'      ---                                    |

  describe 'with plugin_version set' do
    let(:params) do
      {
        config_filename: 'foo.xml',
        changes: [],
        plugin_version: '0.1',
        plugin: true
      }
    end

    it do
      is_expected.to contain_jenkins__plugin('myplug').with(
        version: '0.1',
        manage_config: false
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
    let(:params) do
      {
        plugin: false,
        config_filename: 'foo.xml',
        changes: []
      }
    end

    it do
      is_expected.to contain_augeas('jenkins::augeas: myplug').with(
        incl: '/var/lib/jenkins/foo.xml',
        context: '/files/var/lib/jenkins/foo.xml/',
        lens: 'Xml.lns'
      )
    end
  end

  describe 'with context set' do
    let(:params) do
      {
        plugin: false,
        config_filename: 'foo.xml',
        context: '/foo/bar',
        changes: []
      }
    end

    it do
      is_expected.to contain_augeas('jenkins::augeas: myplug').with(
        incl: '/var/lib/jenkins/foo.xml',
        context: '/files/var/lib/jenkins/foo.xml/foo/bar',
        lens: 'Xml.lns'
      )
    end
  end

  #-------------------------------------------------------------------------------
  #           |         o,---.
  # ,---.,---.|    ,   ..|__.     ,---.,---.,---.,---.,-.-.
  # |   ||   ||    |   |||        |   |,---||    ,---|| | |
  # `---'`   '`---'`---|``        |---'`---^`    `---^` ' '
  #                `---'          |

  [['get foo != bar'], 'get foo != bar'].each do |pval|
    describe "with param onlyif set and class is #{pval.class}" do
      let(:params) do
        {
          plugin: false,
          config_filename: 'foo.xml',
          changes: ['set foo bar'],
          onlyif: pval
        }
      end

      it do
        is_expected.to contain_augeas('jenkins::augeas: myplug').with(
          incl: '/var/lib/jenkins/foo.xml',
          context: '/files/var/lib/jenkins/foo.xml/',
          changes: ['set foo bar'],
          onlyif: pval
        )
      end
    end
  end

  #-------------------------------------------------------------------------------
  #      |
  # ,---.|---.,---.,---.,---.,---.,---.    ,---.,---.,---.,---.,-.-.
  # |    |   |,---||   ||   ||---'`---.    |   |,---||    ,---|| | |
  # `---'`   '`---^`   '`---|`---'`---'    |---'`---^`    `---^` ' '
  #                     `---'              |
  [['set foo bar'], 'set foo bar'].each do |pval|
    describe "with param changes set and class is #{pval.class}" do
      let(:params) do
        {
          plugin: false,
          config_filename: 'foo.xml',
          changes: pval
        }
      end

      it do
        is_expected.to contain_augeas('jenkins::augeas: myplug').with(
          incl: '/var/lib/jenkins/foo.xml',
          changes: pval
        )
      end
    end
  end

  #-------------------------------------------------------------------------------
  #                |              |
  # ,---.,---.,---.|--- ,---.,---.|---     ,---.,---.,---.,---.,-.-.
  # |    |---'`---.|    ,---||    |        |   |,---||    ,---|| | |
  # `    `---'`---'`---'`---^`    `---'    |---'`---^`    `---^` ' '
  #                                        |
  {
    true    => 'safe-restart-jenkins',
    false   => 'reload-jenkins'
  }.each do |pval, expected|
    describe "with param restart set to '#{pval}' (#{pval.class})" do
      let(:params) do
        {
          plugin: false,
          config_filename: 'foo.xml',
          changes: [],
          restart: pval
        }
      end

      it { is_expected.to contain_augeas('jenkins::augeas: myplug').that_notifies("Exec[#{expected}]") }
    end
  end
end
