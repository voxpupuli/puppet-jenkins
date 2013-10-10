# Parameters:
# config_hash = { 'JENKINS_HOME' => { '/var/lib/jenkins' } } (Default)
# Hash with config options to set in sysconfig/jenkins defaults/jenkins
#
# jenkins_home = '/var/lib/jenkins'
#   Home directory of jenkins user.
#
# Example use
#
# class{ 'jenkins::config':
#   config_hash => {
#     'HTTP_PORT' => { 'value' => '9090' }, 'AJP_PORT' => { 'value' => '9009' }
#   }
# }
#
class jenkins::config(
  $config_hash = { },
  $jenkins_home = '/var/lib/jenkins',
) {

  include jenkins::package

  Class['Jenkins::Package']->Class['Jenkins::Config']
  create_resources( 'jenkins::sysconfig', $config_hash )
  create_resources( 'jenkins::sysconfig', {  'JENKINS_HOME' => { 'value' => "$jenkins_home" } } )
}
