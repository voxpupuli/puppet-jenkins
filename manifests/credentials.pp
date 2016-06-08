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
# Type jenkins::credentials
#
# Jenkins credentials (via the CloudBees Credentials plugin
#
define jenkins::credentials (
  $username            = undef,
  $password,
  $description         = 'Managed by Puppet',
  $private_key_or_path = '',
  $ensure              = 'present',
  $uuid                = '',
){
  validate_string($password)
  validate_string($description)
  validate_string($private_key_or_path)
  validate_re($ensure, '^present$|^absent$')
  validate_string($uuid)

  include ::jenkins::cli_helper

  Class['jenkins::cli_helper'] ->
    Jenkins::Credentials[$title] ->
      Anchor['jenkins::end']

  ## Allow multiple users with same username but different credentials
  if $username == undef or $username == '' {
    $_username = $title
  } else {
    $_username = $username
  }
  
  ## Allow multiple users with same username but different credentials
  if $uuid == '' {
    $_exec_comment      = "${_username}"
    $_exec_grep_present = "\\\"${_username}\\\""
    $_exec_grep_absent  = "\\\"${_username}\\\""
  } else {
    $_exec_comment      = "${_username}-${uuid}"
    $_exec_grep_present = "\\\"${_username}\\\""
    $_exec_grep_absent  = "\\\"${uuid}\\\""
  }

  
  case $ensure {
    'present': {
      validate_string($_username)
      jenkins::cli::exec { "create-jenkins-credentials-${_exec_comment}":
        command => [
          'create_or_update_credentials',
          $_username,
          "'${password}'",
          "'${uuid}'",
          "'${description}'",
          "'${private_key_or_path}'",
        ],
        unless  => "\$HELPER_CMD credential_info '${_username}' '${uuid}' | grep -e $_exec_grep_present",
      }
    }
    'absent': {
      jenkins::cli::exec { "delete-jenkins-credentials-${_exec_comment}":
        command => [
          'delete_credentials_by_name_or_id',
          $_username,
          "'${uuid}'",
        ],
        onlyif => "\$HELPER_CMD credential_info '${_username}' '${uuid}' | grep -e $_exec_grep_absent",
      }
    }
    default: {
      fail "ensure must be 'present' or 'absent' but '${ensure}' was given"
    }
  }
}
