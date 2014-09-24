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
  $password,
  $description = 'Managed by Puppet',
  $private_key_or_path = '',
  $ensure = 'present',
){
  validate_string($ensure)

  include ::jenkins::cli_helper

  case $ensure {
    'present': {
      validate_string($password)
      validate_string($description)
      validate_string($private_key_or_path)
      exec { "create-jenkins-credentials-${title}":
        command => join([
          $::jenkins::cli_helper::helper_cmd,
          'create_or_update_credentials',
          $title,
          "'${password}'",
          "'${description}'",
          "'${private_key_or_path}'",
        ], ' '),
        require => Class['::jenkins::cli_helper'],
      }
    }
    'absent': {
      exec { "delete-jenkins-credentials-${title}":
        command => join([
          $::jenkins::cli_helper::helper_cmd,
          'delete_credentials',
          $title,
        ], ' '),
        require => Class['::jenkins::cli_helper'],
      }
    }
    default: {
      fail "ensure must be 'present' or 'absent' but '${ensure}' was given"
    }
  }
}
