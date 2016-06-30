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
){
  validate_string($security_model)
  validate_string($user_realm)
  validate_hash($ldapconfig)

  include ::jenkins::cli_helper

  Class['jenkins::cli_helper'] ->
    Class['jenkins::security'] ->
      Anchor['jenkins::end']

  # XXX not idempotent
  jenkins::cli::exec { "jenkins-security-${security_model}-${user_realm}":
    command => [
      'set_security',
      $security_model,
      $user_realm,
    ],
    require => File['/tmp/ldap_args.json'],
  }

  file { "/tmp/ldap_args.json":
    ensure  => present,
    owner   => 0,
    group   => 0,
    mode    => '0644',
    content => template("${module_name}/ldap_args.json.erb"),
    require => Class['::jenkins::cli_helper'],
  }
}