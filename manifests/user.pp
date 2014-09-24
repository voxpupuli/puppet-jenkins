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
# Type jenkins::user
#
# A Jenkins user account
#
define jenkins::user (
  $email,
  $password,
  $full_name = 'Managed by Puppet',
  $public_key = '',
  $ensure = 'present',
){
  validate_string($ensure)

  include ::jenkins::cli_helper

  case $ensure {
    'present': {
      validate_re($email, '^[^@]+@[^@]+$', "An email address is required, not '${email}'")
      validate_string($password)
      validate_string($full_name)
      validate_string($public_key)
      exec { "create-jenkins-user-${title}":
        command => join([
          $::jenkins::cli_helper::helper_cmd,
          'create_or_update_user',
          $title,
          $email,
          "'${password}'",
          "'${full_name}'",
          "'${public_key}'",
        ], ' '),
        require => Class['::jenkins::cli_helper'],
      }
    }
    'absent': {
      exec { "delete-jenkins-user-${title}":
        command => join([
          $::jenkins::cli_helper::helper_cmd,
          'delete_user',
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
