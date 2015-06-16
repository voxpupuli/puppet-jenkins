# Class: jenkins::repo::debian
#
class jenkins::repo::debian
{
  if $caller_module_name != $module_name {
    fail("Use of private class ${name} by ${caller_module_name}")
  }

  include stdlib
  include apt

  $key_id        = '150FDE3F7787E7D11EF4E12A9B7D32F2D50582E6'
  $key_source    = 'http://pkg.jenkins-ci.org/debian/jenkins-ci.org.key'
  
  # Check for LTS
  if $::jenkins::lts {
    $repo_location = 'http://pkg.jenkins-ci.org/debian-stable'
  } else {
    $repo_location = 'http://pkg.jenkins-ci.org/debian'
  }

  # Check for puppetlabs-apt major version
  if $::jenkins::repo_module_version == 2 {
    $source_keys = {
      key      => {
        id     => $key_id,
        source => $key_source
      },
      include => {
        src => false,
        deb => true
      }
    }
  } else {
    $source_keys = {
      key         => $key_id,
      key_source  => $key_source,
      include_src => false
    }
  }

  # Common hash
  $source_base = {
    location => $repo_location,
    release  => 'binary/',
    repos    => ''
  }

  $result_hash = merge($source_base,$source_keys)
  $resource_hash = { 'jenkins': $result_hash }

  create_resources('apt::source',$resource_hash)

  anchor { 'jenkins::repo::debian::begin': } ->
    Apt::Source['jenkins'] ->
  anchor { 'jenkins::repo::debian::end': }
}
