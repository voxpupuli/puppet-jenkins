#
# This class manages the [Jenkins CI/CD service](https://jenkins.io/index.html).
#
# Note that if different jenkins listening port(s) are configured via
# ``jenkins::port``, ``jenkins::config_hash`` and/or a ``jenkins::sysconf``
# resource, "bad things" are likely to happen.  This is a known implementation
# problem with this module that can not be fixed without breaking backwards
# compatibility.
#
# @param version
#   package to install
#
#   * ``installed`` (Default)
#     do NOT update jenkins to the most recent version.
#   * ``latest``
#    automatically update the version of jenkins to the current version
#    available via your package manager.
#
# @param lts
#   use the upstream jenkins "Long Term Support" repos
#
#   * ``false``
#     Use the most up to date version of jenkins
#   * ``true`` (Default)
#     Use LTS version of jenkins
#
# @param repo
#   configure upstream jenkins package repos
#
#   ``false`` means do NOT configure the upstream jenkins package repo. This
#   means you'll manage a repo manually outside this module.  This is for folks
#   that use a custom repo, or the like.
#
# @param package_name
#   Optionally override the package name
#
# @param direct_download
#   URL to jenkins package
#
#   Ignore repository based package installation and download the package
#   directly.  Leave as `undef` (the default) to download using your OS package
#   manager
#
# @param package_cache_dir
#   Directory in which to store a ``direct_download`` package
#
# @param package_provider
#   Override the ``package`` resource provider
#
#   This *only has effect* when using ``direct_download``.
#
# @param manage_service
#   Enable management of ``Service[jenkins]`` resource
#
#   When setting to ``false`` please ensure something else defines
#   ``Service[jenkins]`` in order for some module functionality (e.g.
#   ``jenkins::cli``) to work properly
#
# @param service_enable
#   Enable (or not) the jenkins service
#
# @param service_ensure
#   Status of the jenkins service
#
#   * ``running`` (default)
#   * ``stopped``
#
# @param service_provider
#   Override ``Service[jenkins]`` resource provider
#
#   Setting this to ``undef`` on platforms with ``systemd`` will force the
#   usage of package provider sysv init scripts.
#
# @param config_hash
#   options to set in sysconfig/jenkins defaults/jenkins
#
#   (see jenkins::sysconf)
#
# @example Bulk sysconf
#   class{ 'jenkins':
#     config_hash => {
#       'HTTP_PORT' => { 'value' => '9090' },
#       'AJP_PORT'  => { 'value' => '9009' },
#     }
#   }
#
# @param plugin_hash
#   plugins to install
#
#   (see jenkins::plugin)
#
# @example Bulk plugin installation (code)
#   class{ 'jenkins::plugins':
#     plugin_hash => {
#       'git' => { version => '1.1.1' },
#       'parameterized-trigger' => {},
#       'multiple-scms' => {},
#       'git-client' => {},
#       'token-macro' => {},
#     }
#   }
#
# @example Bulk plugin installation (hiera)
#   jenkins::plugin_hash:
#      git:
#         version: '1.1.1'
#      parameterized-trigger: {}
#      multiple-scms: {}
#      git-client: {}
#      token-macro: {}
#
# @param job_hash
#   jobs to install
#
#   (see jenkins::job)
#
# @param user_hash
#   jenkins users to create
#
# @example Bulk user creation (code)
#   class{ 'jenkins':
#     user_hash => {
#       'user1' => {
#         'password' => 'pass1',
#          'email'   => 'user1@example.com',
#       }
#     }
#   }
#
# @example Bulk user creation (hiera)
#   jenkins::user_hash:
#     user:
#       password: 'pass1'
#       email: 'user1@example.com'
#
# @param configure_firewall
#   For folks that want to manage the puppetlabs firewall module.
#
#    * If it's not present in the catalog, nothing happens.
#    * If it is, you need to explicitly set this true / false.
#       * We didn't want you to have a service opened automatically, or
#       unreachable inexplicably.
#    * This default changed in v1.0 to be undef.
#
# @param install_java
#   use the ``puppetlabs-java`` module to install a JDK
#
#   Jenkins requires a JRE. Setting this to ``false`` means that you are
#   response for managing a JDK outside of this module.
#
# @param repo_proxy
#   proxy to download packages
#
#   This parameter is only relevant for ``yum`` repos managed by this module.
#
# @param proxy_host
#   proxy hostname for plugin installation via this module and the UpdateCenter
#
# @param proxy_port
#   proxy port for plugin installation via this module and the UpdateCenter
#
# @param no_proxy_list
#   List of hostname patterns to skip using the proxy.
#
#   * Only effective if "proxy_host" and "proxy_port" are set.
#   * Only applies to plugins installed via the UpdateCenter
#
# @param cli
#   install ``jenkins-cli.jar`` CLI utility
#
#   * force installation of the jenkins CLI jar to
#   ``$libdir/cli/jenkins-cli.jar``
#   * the cli is automatically installed when needed by components that use it,
#     such as the user and credentials types, and the security class
#   * CLI installation (both implicit and explicit) requires the ``unzip``
#   command
#
# @param cli_ssh_keyfile
#   Provides the location of an ssh private key file to make authenticated
#   connections to the Jenkins CLI.
#
# @param cli_tries
#   Retries until giving up talking to jenkins API
#
# @param cli_try_sleep
#   Seconds between tries to contact jenkins API
#
# @param port
#   Jenkins listening HTTP port
#
#   Note that this value is used for CLI communication and firewall
#   configuration.  It does not configure the port on which the jenkins service
#   listens. (see config_hash)
# @param libdir
#   Path to jenkins core files
#
#   * Redhat: ``/usr/lib/jenkins``
#   * Debian: ``/usr/share/jenkins``
#
# @param sysconfdir
#   Controls the path to the "sysconfig" file that stores jenkins service
#   start-up variables
#
#   * RedHat: ``/etc/sysconfig/jenkins``
#   * Debian: ``/etc/default/jenkins``
#
# @param manage_datadirs
#   manage the local state dir, plugins dir and jobs dir
#
# @param localstatedir
#   base path, in the ``autoconf`` sense, for jenkins local data including jobs
#   and plugins
#
# @param executors
#   number of executors on the Jenkins master
#
# @param slaveagentport
#   jenkins slave agent
#
# @param manage_user
#   manage the system jenkins user
#
# @param user
#   system user that owns the jenkins master's files
#
# @param manage_group
#   manage the system jenkins group
#
# @param group
#   system group that owns the jenkins master's files
#
# @param default_plugins
#   List of default plugins installed by this module
#
#   The the ``credentials`` plugin is required for this module to properly
#   function.  No version is specified.  Set to ``[]`` if you want to explicitly
#   manage all plugins version
#
# @param default_plugins_host
#   Provide a way to override plugins host for all plugins
#
# @example Manage version of ``credentials`` plugin (hiera)
#   jenkins::default_plugins: []
#   jenkins::plugin_hash:
#     credentials:
#       version: 2.1.5
#       digest_string: 7db002e7b053f863e2ce96fb58abb98a9c01b09c
#       digest_type: sha1
#
# @param purge_plugins
#   Purge *all* plugins not explicitly managed by this module
#
#   This will result in plugins manually installed via the UpdateCenter being
#   removed.  Only enable this option if you want to manage all plugins (and
#   plugin dependencies) explicitly.
#
# @example Explicitly manage *all* plugins (hiera)
#   jenkins::default_plugins: []
#   jenkins::purge_plugins: true
#   jenkins::plugin_hash:
#     credentials:
#       version: '2.1.10'
#     support-core:
#       version: '2.38'
#     # support-core deps
#     metrics:
#       version: '3.1.2.9'
#     jackson2-api:
#       version: '2.7.3'
#     bouncycastle-api:
#       version: '2.16.0'
#     # /support-core deps
#
class jenkins(
  $version              = $jenkins::params::version,
  $lts                  = $jenkins::params::lts,
  $repo                 = $jenkins::params::repo,
  $package_name         = $jenkins::params::package_name,
  $direct_download      = $::jenkins::params::direct_download,
  $package_cache_dir    = $jenkins::params::package_cache_dir,
  $package_provider     = $jenkins::params::package_provider,
  $manage_service       = true,
  $service_enable       = $jenkins::params::service_enable,
  $service_ensure       = $jenkins::params::service_ensure,
  $service_provider     = $jenkins::params::service_provider,
  $config_hash          = {},
  $plugin_hash          = {},
  $job_hash             = {},
  $user_hash            = {},
  $configure_firewall   = false,
  $install_java         = $jenkins::params::install_java,
  $repo_proxy           = undef,
  $proxy_host           = undef,
  $proxy_port           = undef,
  $no_proxy_list        = undef,
  $cli                  = true,
  $cli_ssh_keyfile      = undef,
  $cli_tries            = $jenkins::params::cli_tries,
  $cli_try_sleep        = $jenkins::params::cli_try_sleep,
  $port                 = $jenkins::params::port,
  $libdir               = $jenkins::params::libdir,
  $sysconfdir           = $jenkins::params::sysconfdir,
  $manage_datadirs      = $jenkins::params::manage_datadirs,
  $localstatedir        = $::jenkins::params::localstatedir,
  $executors            = undef,
  $slaveagentport       = undef,
  $manage_user          = $::jenkins::params::manage_user,
  $user                 = $::jenkins::params::user,
  $manage_group         = $::jenkins::params::manage_group,
  $group                = $::jenkins::params::group,
  $default_plugins      = $::jenkins::params::default_plugins,
  $default_plugins_host = $::jenkins::params::default_plugins_host,
  $purge_plugins        = $::jenkins::params::purge_plugins,
) inherits jenkins::params {

  validate_string($version)
  validate_bool($lts)
  validate_bool($repo)
  validate_string($package_name)
  validate_string($direct_download)
  validate_absolute_path($package_cache_dir)
  validate_string($package_provider)
  validate_bool($manage_service)
  validate_bool($service_enable)
  validate_re($service_ensure, '^running$|^stopped$')
  validate_string($service_provider)
  validate_hash($config_hash)
  validate_hash($plugin_hash)
  validate_hash($job_hash)
  validate_hash($user_hash)
  validate_bool($configure_firewall)
  validate_bool($install_java)
  validate_string($repo_proxy)
  validate_string($proxy_host)
  if $proxy_port { validate_integer($proxy_port) }
  if $no_proxy_list { validate_array($no_proxy_list) }
  validate_bool($cli)
  if $cli_ssh_keyfile { validate_absolute_path($cli_ssh_keyfile) }
  validate_integer($cli_tries)
  validate_integer($cli_try_sleep)
  validate_integer($port)
  validate_absolute_path($libdir)
  validate_absolute_path($sysconfdir)
  validate_bool($manage_datadirs)
  validate_absolute_path($localstatedir)
  if $executors { validate_integer($executors) }
  if $slaveagentport { validate_integer($slaveagentport) }
  validate_bool($manage_user)
  validate_string($user)
  validate_bool($manage_group)
  validate_string($group)
  validate_string($default_plugins_host)
  validate_bool($purge_plugins)
  if $purge_plugins and ! $manage_datadirs {
    warning('jenkins::purge_plugins has no effect unless jenkins::manage_datadirs is true')
  }

  $plugin_dir = "${localstatedir}/plugins"
  $job_dir = "${localstatedir}/jobs"

  anchor {'jenkins::begin':}
  anchor {'jenkins::end':}

  if $install_java {
    include ::java
  }

  if $direct_download {
    $repo_ = false
    $jenkins_package_class = 'jenkins::direct_download'
  } else {
    $jenkins_package_class = 'jenkins::package'
    if $repo {
      $repo_ = true
      include ::jenkins::repo
    } else {
      $repo_ = false
    }
  }
  include $jenkins_package_class

  include ::jenkins::config
  include ::jenkins::plugins
  include ::jenkins::jobs
  include ::jenkins::users
  include ::jenkins::proxy

  if $manage_service {
    include ::jenkins::service
    validate_array($default_plugins)
    if empty($default_plugins){
      notice(sprintf('INFO: make sure you install the following plugins with your code using this module: %s',join($::jenkins::params::default_plugins,','))) # lint:ignore:140chars
    }
  }

  if defined('::firewall') {
    if $configure_firewall == undef {
      fail('The firewall module is included in your manifests, please configure $configure_firewall in the jenkins module')
    } elsif $configure_firewall {
      include ::jenkins::firewall
    }
  }

  if $cli {
    include ::jenkins::cli
    include ::jenkins::cli_helper
  }

  if $executors {
    jenkins::cli::exec { 'set_num_executors':
      command => ['set_num_executors', $executors],
      unless  => "[ \$(\$HELPER_CMD get_num_executors) -eq ${executors} ]",
    }

    Class['jenkins::cli'] ->
      Jenkins::Cli::Exec['set_num_executors'] ->
        Class['jenkins::jobs']
  }

  if ($slaveagentport != undef) {
    jenkins::cli::exec { 'set_slaveagent_port':
      command => ['set_slaveagent_port', $slaveagentport],
      unless  => "[ \$(\$HELPER_CMD get_slaveagent_port) -eq ${slaveagentport} ]",
    }

    Class['jenkins::cli'] ->
      Jenkins::Cli::Exec['set_slaveagent_port'] ->
        Class['jenkins::jobs']
  }

  if $manage_service {
    Anchor['jenkins::begin'] ->
      Class[$jenkins_package_class] ->
        Class['jenkins::config'] ->
          Class['jenkins::plugins'] ~>
            Class['jenkins::service'] ->
              Class['jenkins::jobs'] ->
                Anchor['jenkins::end']
  }

  if $install_java {
    Anchor['jenkins::begin'] ->
      Class['java'] ->
        Class[$jenkins_package_class] ->
          Anchor['jenkins::end']
  }

  if $repo_ {
    Anchor['jenkins::begin'] ->
      Class['jenkins::repo'] ->
        Class['jenkins::package'] ->
          Anchor['jenkins::end']
  }

  if ($configure_firewall and $manage_service) {
    Class['jenkins::service'] ->
      Class['jenkins::firewall'] ->
        Anchor['jenkins::end']
  }

  if $service_provider == 'systemd' {
    jenkins::systemd { 'jenkins':
      user   => $user,
      libdir => $libdir,
    }

    # jenkins::config manages the jenkins user resource, which is autorequired
    # by the file resource for the run wrapper.
    Class['jenkins::config'] ->
      Jenkins::Systemd['jenkins'] ->
        Anchor['jenkins::end']
  }
}
# vim: ts=2 et sw=2 autoindent
