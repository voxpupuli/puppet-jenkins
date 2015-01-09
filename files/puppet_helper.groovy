// Copyright 2010 VMware, Inc.
// Copyright 2011 Fletcher Nichol
// Copyright 2013-2014 Chef Software, Inc.
// Copyright 2014 RetailMeNot, Inc.
// 
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
// 
//     http://www.apache.org/licenses/LICENSE-2.0
// 
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import com.cloudbees.jenkins.plugins.sshcredentials.impl.*
import com.cloudbees.jenkins.plugins.sshcredentials.impl.*;
import com.cloudbees.plugins.credentials.*
import com.cloudbees.plugins.credentials.*;
import com.cloudbees.plugins.credentials.common.*
import com.cloudbees.plugins.credentials.domains.*
import com.cloudbees.plugins.credentials.domains.*;
import com.cloudbees.plugins.credentials.impl.*
import com.cloudbees.plugins.credentials.impl.*
import groovy.json.JsonBuilder
import groovy.json.JsonSlurper
import hudson.model.User;
import hudson.plugins.sshslaves.*
import hudson.security.ACL
import hudson.security.AuthorizationStrategy
import hudson.security.FullControlOnceLoggedInAuthorizationStrategy
import hudson.security.GlobalMatrixAuthorizationStrategy
import hudson.security.HudsonPrivateSecurityRealm
import hudson.security.LDAPSecurityRealm
import hudson.security.Permission
import hudson.util.Secret;
import jenkins.model.*
import jenkins.security.ApiTokenProperty;

class InvalidAuthenticationStrategy extends Exception{}
class CanNotLoadJsonMapFileException extends Exception{}

///////////////////////////////////////////////////////////////////////////////
// Actions
///////////////////////////////////////////////////////////////////////////////

class Actions {
  Actions(out) { this.out = out }
  def out

  private static credentials_for_username(String username) {
    def username_matcher = CredentialsMatchers.withUsername(username)
    def available_credentials =
            CredentialsProvider.lookupCredentials(
                    StandardUsernameCredentials.class,
                    Jenkins.getInstance(),
                    ACL.SYSTEM,
                    new SchemeRequirement("ssh")
            )

    return CredentialsMatchers.firstOrNull(
            available_credentials,
            username_matcher
    )
  }

  private loadJsonMap(String mapFileName) {
    File mapFile = new File(mapFileName)
    if (!mapFile.exists()) {
      throw new CanNotLoadJsonMapFileException("JSON map file ${mapFileName} does not exist")
    } else {
      def slurper = new JsonSlurper()
      return slurper.parseText(mapFile.text)
    }
  }

  public getActionAndOptionMap(cliArgs) {
    def cli = Jenkins.instance.pluginManager.uberClassLoader.findClass("groovy.util.CliBuilder").newInstance(usage: "puppet_helper.groovy - only called by puppet!")

    cli._(longOpt:'action', args:1, required:true, "Action to invoke")

    cli._(longOpt:'user_name', args:1, "Used in create_or_update_user, delete_user, user_info, create_or_update_credentials, delete_credentials, credential_info")

    cli._(longOpt:'email', args:1, "Used in create_or_update_user")

    cli._(longOpt:'password', args:1, "Used in create_or_update_user, create_or_update_credentials")

    cli._(longOpt:'full_name', args:1, "Used in create_or_update_user")

    cli._(longOpt:'public_keys', args:1, "Used in create_or_update_user")

    cli._(longOpt:'description', args:1, "Used in create_or_update_credentials")

    cli._(longOpt:'private_key', args:1, "Used in create_or_update_credentials")

    cli._(longOpt:'security_model', args:1, "Used in set_security")

    cli._(longOpt:'user_realm', args:1, "Used in set_security")

    cli._(longOpt:'ldap_config_file', args:1, "JSON file containing LDAP configuration. Required for ldap user_realm.")

    cli._(longOpt:'matrix_auth_config_file', args:1, "JSON file containing array of permission strings. Required for global_matrix security model.")

    def opts = cli.parse(cliArgs)

    def optMap = [:]

    opts.getOptions().each { opt ->
      if (opt.getLongOpt() != "action") {
        optMap[opt.getLongOpt()] = opt.getValue() ?: ""
      }
    }

    return [opts.action, optMap]
  }

  /**
   * create or update user
   */
  void create_or_update_user(Map args) {
    def user = User.get(args.username)
    user.setFullName(args.full_name)

    def email_param = new hudson.tasks.Mailer.UserProperty(args.email)
    user.addProperty(email_param)

    def pw_param = HudsonPrivateSecurityRealm.Details.fromPlainPassword(args.password)
    user.addProperty(pw_param)

    if ( args.public_keys != "" ) {
      def keys_param = new org.jenkinsci.main.modules.cli.auth.ssh.UserPropertyImpl(args.public_keys)
      user.addProperty(keys_param)
    }

    user.save()
  }

  /**
   * delete user
   */
  void delete_user(Map args) {
    def user = User.get(args.username, false)
    if (user != null) {
      user.delete()
    }
  }

  /**
   * current user
   */
  void user_info(Map args) {
    def user = hudson.model.User.get(args.username, false)

    if(user == null) {
      return
    }

    def user_id = user.getId()
    def name = user.getFullName()

    def email_address = null
    def emailProperty = user.getProperty(hudson.tasks.Mailer.UserProperty)
    if(emailProperty != null) {
      email_address = emailProperty.getAddress()
    }

    def keys = null
    def keysProperty = user.getProperty(org.jenkinsci.main.modules.cli.auth.ssh.UserPropertyImpl)
    if(keysProperty != null) {
      keys = keysProperty.authorizedKeys.split('\\s+')
    }

    def token = null
    def tokenProperty = user.getProperty(ApiTokenProperty.class)
    if (tokenProperty != null) {
      token = tokenProperty.getApiToken()
    }

    def builder = new JsonBuilder()
    builder {
      id user_id
      full_name name
      email email_address
      api_token token
      public_keys keys
    }

    out.println(builder)
  }

  /**
   * create credentials
   */
  void create_or_update_credentials(Map args) {
    def global_domain = Domain.global()
    def credentials_store =
            Jenkins.instance.getExtensionList(
                    'com.cloudbees.plugins.credentials.SystemCredentialsProvider'
            )[0].getStore()

    def credentials
    if (args.private_key == "" ) {
      credentials = new UsernamePasswordCredentialsImpl(
              CredentialsScope.GLOBAL,
              null,
              args.description,
              args.username,
              args.password
      )
    } else {
      def key_source
      if (args.private_key.startsWith('-----BEGIN')) {
        key_source = new BasicSSHUserPrivateKey.DirectEntryPrivateKeySource(private_key)
      } else {
        key_source = new BasicSSHUserPrivateKey.FileOnMasterPrivateKeySource(private_key)
      }
      credentials = new BasicSSHUserPrivateKey(
              CredentialsScope.GLOBAL,
              null,
              args.username,
              key_source,
              args.password,
              args.description
      )
    }

    // Create or update the credentials in the Jenkins instance
    def existing_credentials = credentials_for_username(args.username)

    if(existing_credentials != null) {
      credentials_store.updateCredentials(
              global_domain,
              existing_credentials,
              credentials
      )
    } else {
      credentials_store.addCredentials(global_domain, credentials)
    }
  }

  /**
   * delete credentials
   */
  void delete_credentials(Map args) {
    def existing_credentials = credentials_for_username(args.username)

    if(existing_credentials != null) {
      def global_domain = Domain.global()
      def credentials_store =
              Jenkins.instance.getExtensionList(
                      'com.cloudbees.plugins.credentials.SystemCredentialsProvider'
              )[0].getStore()
      credentials_store.removeCredentials(
              global_domain,
              existing_credentials
      )
    }
  }

  /**
   * current credentials
   */
  void credential_info(Map args) {
    def credentials = credentials_for_username(args.username)

    if(credentials == null) {
      return
    }

    def current_credentials = [
            id:credentials.id,
            description:credentials.description,
            username:credentials.username
    ]

    if ( credentials.hasProperty('password') ) {
      current_credentials['password'] = credentials.password.plainText
    } else {
      current_credentials['private_key'] = credentials.privateKey
      current_credentials['passphrase'] = credentials.passphrase.plainText
    }

    def builder = new JsonBuilder(current_credentials)
    out.println(builder)
  }

  /**
   * Set up security for the Jenkins instance. This currently supports
   * only a small number of configurations. If authentication is enabled, it
   * uses the internal user database if the user_realm isn't set or is set to
   * 'internal', and LDAP if set to 'ldap'.
   */
  void set_security(Map args) {
    def instance = Jenkins.getInstance()

    if (args.security_model == 'disabled') {
      instance.disableSecurity()
      return
    }

    Map ldapMap = [:]

    if (args.ldap_config_file != null) {
      ldapMap = loadJsonMap(args.load_config_file)
    }

    if (ldapMap.isEmpty() && args.user_realm == "ldap") {
      throw new InvalidAuthenticationStrategy("LDAP user realm specified but no LDAP config provided")
    }

    List matrixAuthMap = []

    if (args.matrix_auth_config_file != null) {
      matrixAuthMap = loadJsonMap(args.matrix_auth_config_file)
    }

    if (matrixAuthMap.isEmpty() && args.security_model == "global_matrix") {
      throw new InvalidAuthenticationStrategy("Global matrix security model specified but no permissions config provided")
    }

    def strategy
    def realm
    switch (args.security_model) {
      case 'full_control':
        strategy = new FullControlOnceLoggedInAuthorizationStrategy()
        break
      case 'unsecured':
        strategy = new AuthorizationStrategy.Unsecured()
        break
      case 'global_matrix':
        strategy = new GlobalMatrixAuthorizationStrategy()
        matrixAuthMap.each { String permString ->
          if (!permString.contains(":")) {
            throw new InvalidAuthenticationStrategy("Invalid permission string ${permString}")
          } else {
            def permAndUser = permString.split(":")
            Permission p = Permission.fromId(permAndUser[0])
            if (p == null) {
              throw new InvalidAuthenticationStrategy("Invalid permission value ${permAndUser[0]}")
            }
            strategy.add(p, permAndUser[1])
          }
        }
        break
      default:
        throw new InvalidAuthenticationStrategy()
    }

    switch (args.user_realm) {
      case ['internal', '']:
        realm = new HudsonPrivateSecurityRealm(false, false, null)
        break
      case 'ldap':
        realm = new LDAPSecurityRealm(ldapMap.server,
                ldapMap.rootDN,
                ldapMap.userSearchBase,
                ldapMap.userSearch,
                ldapMap.groupSearchBase,
                ldapMap.groupSearchFilter,
                null,
                ldapMap.managerDN,
                Secret.fromString(ldapMap.managerPasswordSecret ?: ""),
                Boolean.parseBoolean(ldapMap.inhibitInferRootDN ?: "false"),
                Boolean.parseBoolean(ldapMap.disableMailAddressResolver ?: "false"),
                null,
                null,
                ldapMap.displayNameAttributeName,
                ldapMap.mailAddressAttributeName)
        break
      default:
        throw new InvalidAuthenticationStrategy()
    }

    instance.setAuthorizationStrategy(strategy)
    instance.setSecurityRealm(realm)
  }
} // class Actions

///////////////////////////////////////////////////////////////////////////////
// CLI Argument Processing
///////////////////////////////////////////////////////////////////////////////

actions = new Actions(out)

def argResult = actions.getActionAndOptionMap(args)
def action = argResult[0]
def optMap = argResult[1]

if (args.length < 2) {
  actions."$action"()
} else {
  actions."$action"(optMap)
}
