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
  $jenkins_management = {},
  $jenkins_s2m_acl = false,
  $security_model  = undef,
){
  validate_string($security_model)

  include ::jenkins::cli_helper

  if ($security_model == 'unsecured') {
    $security_opt_params = 'set_security_unsecured'
  }

  if ($security_model == 'ldap') {
    include ::jenkins::ldap::config
    $jenkins_ssh_public_key_contents = file('${libdir}/.ssh/id_rsa.pub')
    $security_opt_params = join([
      'set_security_ldap',
      "'${ldap_config}[ldap_overwrite_permissions]'",
      "'${ldap_config}[ldap_access_group]'",
      "'${ldap_config}[ldap_uri]'",
      "'${ldap_config}[ldap_root_dn]'",
      "'${ldap_config}[ldap_user_search]'",
      "'${ldap_config}[ldap_inhibit_root_dn]'",
      "'${ldap_config}[ldap_user_search_base]'",
      "'${ldap_config}[ldap_group_search_base]'",
      "'${ldap_config}[ldap_manager]'",
      "'${ldap_config}[ldap_manager_passwd]'",
      "'${jenkins_management_login}'",
      "'${jenkins_management_email}'",
      "'${jenkins_management_password}'",
      "'${jenkins_management_name}'",
      "'${jenkins_ssh_public_key_contents}'",
      "'${jenkins_s2m_acl}'",
    ], ' ')
  }

  if ($security_model == 'password') {
    $jenkins_ssh_public_key_contents = file('${libdir}/.ssh/id_rsa.pub')
    $security_opt_params = join([
      'set_security_password',
      "'${jenkins_management_login}'",
      "'${jenkins_management_email}'",
      "'${jenkins_management_password}'",
      "'${jenkins_management_name}'",
      "'${jenkins_ssh_public_key_contents}'",
      "'${jenkins_s2m_acl}'",
    ], ' ')
  }

  # XXX not idempotent
  jenkins::cli::exec { "jenkins-security-${security_model}":
    command => [
      $security_opt_params
    ],
    user    => 'jenkins',
  }
}
