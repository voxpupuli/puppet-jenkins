# Jenkins ldap configuration
#
class jenkins::ldap::config (
  $ldap_config = {
    'jenkins_management_email'=> '',
    'jenkins_management_login'=> '',
    'jenkins_management_name' => '',
    'jenkins_management_password' => '',
    'ldap_access_group' => '',
    'ldap_group_search_base' => '',
    'ldap_inhibit_root_dn' => '',
    'ldap_manager' => 'ldap-manager',
    'ldap_manager_passwd' => 'ldap-password',
    'ldap_overwrite_permissions' => 'true',
    'ldap_root_dn' => 'dc=company,dc=net',
    'ldap_uri' => 'ldap://ldap',
    'ldap_user_search' => 'uid={0}',
    'ldap_user_search_base' => '',
  }
)

