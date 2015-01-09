# Copyright 2014 RetailMeNot, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#     http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# Class jenkins::security
#
# Jenkins security configuration
#
class jenkins::security (
  $security_model = undef,
  $user_realm     = 'internal',
  $ldapconfig     = {},
  $permisssions   = [],
  ){

  validate_string($security_model)
  validate_string($user_realm)

  include ::jenkins::cli_helper

  file { "/tmp/ldap_args.json":
    ensure  => present,
    owner   => 0,
    group   => 0,
    mode    => '0644',
    content => template("${module_name}/ldap_args.json.erb",
  }
  

  file { "/tmp/perm_args.json":
    ensure  => present,
    owner   => 0,
    group   => 0,
    mode    => '0644',
    content => template("${module_name}/perm_args.json.erb",
  }

  exec { "jenkins-security-${security_model}-${user_realm}":
    command => join([
                     $::jenkins::cli_helper::helper_cmd,
                     "--action=set_security",
                     "--security_model=${security_model}",
                     "--user_realm=${user_realm}",
                     "--ldap_config_file=/tmp/ldap_args.json",
                     "--matrix_auth_config_file=/tmp/perm_args.json",
                     ], ' '),
    require => [
                File['/tmp/ldap_args.json'],
                Class['::jenkins::cli_helper'],
                File['/tmp/perm_args.json'],
                ],
  }
}
