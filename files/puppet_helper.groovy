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
import com.cloudbees.plugins.credentials.impl.*;
import hudson.plugins.sshslaves.*;
import jenkins.model.*;
import hudson.model.*;

class InvalidAuthenticationStrategy extends Exception{}

///////////////////////////////////////////////////////////////////////////////
// Util
///////////////////////////////////////////////////////////////////////////////

// Private methods don't appear to be "private" under groovy.  This utility
// class is for methods that should not be exposed as CLI options via the
// Action class.
class Util {
  Util(out) { this.out = out }
  def out

  def credentials_for_username(String username) {
    def username_matcher = CredentialsMatchers.withUsername(username)
    def available_credentials =
      CredentialsProvider.lookupCredentials(
        StandardUsernameCredentials.class,
        Jenkins.getInstance(),
        hudson.security.ACL.SYSTEM,
        new SchemeRequirement("ssh")
      )

    return CredentialsMatchers.firstOrNull(
      available_credentials,
      username_matcher
    )
  }

  def userToMap(User user) {
    def conf = [:]

    conf['id'] = user.getId()

    // it isn't clear if fullName can be null or if it will always default to
    // id
    def full_name = user.getFullName()
    if (full_name != null) {
      conf['full_name'] = user.getFullName()
    }

    def emailProperty = user.getProperty(hudson.tasks.Mailer.UserProperty)
    if (emailProperty != null) {
      def email_address = emailProperty.getAddress()
      if (email_address != null) {
        conf['email_address'] = emailProperty.getAddress()
      }
    }

    def keysProperty = user.getProperty(org.jenkinsci.main.modules.cli.auth.ssh.UserPropertyImpl)
    if(keysProperty != null) {
      conf['public_keys'] = keysProperty.authorizedKeys.split('\\n')
    }

    def tokenProperty = user.getProperty(jenkins.security.ApiTokenProperty)
    if (tokenProperty != null) {
      conf['api_token_public'] = tokenProperty.getApiToken()
      conf['api_token_plain'] = tokenProperty.@apiToken.getPlainText()
    }

    def passwordProperty = user.getProperty(hudson.security.HudsonPrivateSecurityRealm.Details)
    if (passwordProperty != null) {
      conf['password'] = passwordProperty.getPassword()
    }

    conf
  }
} // class Util

///////////////////////////////////////////////////////////////////////////////
// Actions
///////////////////////////////////////////////////////////////////////////////

class Actions {
  Actions(out, bindings) {
    this.out = out
    this.bindings = bindings
    this.util = new Util(out)
  }
  def out
  def bindings
  def util


  /////////////////////////
  // create or update user
  /////////////////////////
  void create_or_update_user(String user_name, String email, String password="", String full_name="", String public_keys="") {
    def user = hudson.model.User.get(user_name)
    user.setFullName(full_name)

    def email_param = new hudson.tasks.Mailer.UserProperty(email)
    user.addProperty(email_param)

    def pw_param = hudson.security.HudsonPrivateSecurityRealm.Details.fromPlainPassword(password)
    user.addProperty(pw_param)

    if ( public_keys != "" ) {
      def keys_param = new org.jenkinsci.main.modules.cli.auth.ssh.UserPropertyImpl(public_keys)
      user.addProperty(keys_param)
    }

    user.save()
  }

  /////////////////////////
  // delete user
  /////////////////////////
  void delete_user(String user_name) {
    def user = hudson.model.User.get(user_name, false)
    if (user != null) {
      user.delete()
    }
  }

  /////////////////////////
  // current user
  /////////////////////////
  void user_info(String user_name) {
    def user = hudson.model.User.get(user_name, false)

    if (user == null) {
        return null
    }

    def info = util.userToMap(user)
    def builder = new groovy.json.JsonBuilder(info)

    out.println(builder.toPrettyString())
  }

  /////////////////////////
  // create credentials
  /////////////////////////
  void create_or_update_credentials(String username, String password, String description="", String private_key="") {
    def global_domain = Domain.global()
    def credentials_store =
      Jenkins.instance.getExtensionList(
        'com.cloudbees.plugins.credentials.SystemCredentialsProvider'
      )[0].getStore()

    def credentials
    if (private_key == "" ) {
      credentials = new UsernamePasswordCredentialsImpl(
        CredentialsScope.GLOBAL,
        null,
        description,
        username,
        password
      )
    } else {
      def key_source
      if (private_key.startsWith('-----BEGIN')) {
        key_source = new BasicSSHUserPrivateKey.DirectEntryPrivateKeySource(private_key)
      } else {
        key_source = new BasicSSHUserPrivateKey.FileOnMasterPrivateKeySource(private_key)
      }
      credentials = new BasicSSHUserPrivateKey(
        CredentialsScope.GLOBAL,
        null,
        username,
        key_source,
        password,
        description
      )
    }

    // Create or update the credentials in the Jenkins instance
    def existing_credentials = util.credentials_for_username(username)

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

  //////////////////////////
  // delete credentials
  //////////////////////////
  void delete_credentials(String username) {
    def existing_credentials = util.credentials_for_username(username)

    if(existing_credentials != null) {
      def global_domain = com.cloudbees.plugins.credentials.domains.Domain.global()
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

  ////////////////////////
  // current credentials
  ////////////////////////
  void credential_info(String username) {
    def credentials = util.credentials_for_username(username)

    if(credentials == null) {
      return null
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

    def builder = new groovy.json.JsonBuilder(current_credentials)
    out.println(builder)
  }

  //////////////////////////////
  // enable slave to master acl
  //////////////////////////////
  void enable_slave_to_master_acl(String act) {
    def s2m = new AdminWhitelistRule()
    if(act == "true") {
      // for 'enabled' state we need to pass 'false'
      s2m.setMasterKillSwitch(false)
    }
    if(act == "false") {
      s2m.setMasterKillSwitch(true)
    }
    // requires Jenkins restart
    Hudson.instance.safeRestart()
  }

  //////////////////////////////
  // set security ldap
  //////////////////////////////
  void set_security_ldap(
    String overwrite_permissions=null,
    String item_perms=null,
    String server=null,
    String rootDN=null,
    String userSearch=null,
    String inhibitInferRootDN=null,
    String userSearchBase=null,
    String groupSearchBase=null,
    String managerDN=null,
    String managerPassword=null,
    String ldapuser,
    String email=null,
    String password,
    String name=null,
    String pub_keys=null,
    String s2m_acl=null
  ) {

    if (inhibitInferRootDN==null) {
      inhibitInferRootDN = false
    }
    def instance = Jenkins.getInstance()
    def strategy
    def realm
    List users = item_perms.split(' ')

    if (!(instance.getAuthorizationStrategy() instanceof hudson.security.GlobalMatrixAuthorizationStrategy)) {
      overwrite_permissions = 'true'
    }
    create_or_update_user(ldapuser, email, password, name, pub_keys)
    strategy = new hudson.security.GlobalMatrixAuthorizationStrategy()
    for (String user : users) {
      for (Permission p : Item.PERMISSIONS.getPermissions()) {
        strategy.add(p,user)
      }
      for (Permission p : Computer.PERMISSIONS.getPermissions()) {
        strategy.add(p,user)
      }
      for (Permission p : Hudson.PERMISSIONS.getPermissions()) {
        strategy.add(p,user)
      }
      for (Permission p : Run.PERMISSIONS.getPermissions()) {
        strategy.add(p,user)
      }
      for (Permission p : View.PERMISSIONS.getPermissions()) {
        strategy.add(p,user)
      }
    }
    realm = new hudson.security.LDAPSecurityRealm(
      server, rootDN, userSearchBase, userSearch, groupSearchBase, managerDN, managerPassword, inhibitInferRootDN.toBoolean()
    )
    // apply new strategy&realm
    if (overwrite_permissions == 'true') {
      instance.setAuthorizationStrategy(strategy)
    }
    instance.setSecurityRealm(realm)
    // commit new settings permanently (in config.xml)
    instance.save()
    // now setup s2m if requested
    if(s2m_acl == 'true') {
      enable_slave_to_master_acl(s2m_acl)
    }
  }

  //////////////////////////////
  // set security unsecured
  //////////////////////////////
  void set_security_unsecured() {
    def instance = Jenkins.getInstance()
    def strategy
    def realm
    strategy = new hudson.security.AuthorizationStrategy.Unsecured()
    realm = new hudson.security.HudsonPrivateSecurityRealm(false, false, null)
    instance.setAuthorizationStrategy(strategy)
    instance.setSecurityRealm(realm)
    instance.save()
  }

  //////////////////////////////
  // set security password
  //////////////////////////////
  void set_security_password(String user, String email, String password, String name=null, String pub_keys=null, String s2m_acl=null) {
    def instance = Jenkins.getInstance()
    def overwrite_permissions
    def strategy
    def realm
    strategy = new hudson.security.GlobalMatrixAuthorizationStrategy()
    if (!(instance.getAuthorizationStrategy() instanceof hudson.security.GlobalMatrixAuthorizationStrategy)) {
      overwrite_permissions = 'true'
    }
    create_or_update_user(user, email, password, name, pub_keys)
    for (Permission p : Item.PERMISSIONS.getPermissions()) {
      strategy.add(p,user)
    }
    for (Permission p : Computer.PERMISSIONS.getPermissions()) {
      strategy.add(p,user)
    }
    for (Permission p : Hudson.PERMISSIONS.getPermissions()) {
      strategy.add(p,user)
    }
    for (Permission p : Run.PERMISSIONS.getPermissions()) {
      strategy.add(p,user)
    }
    for (Permission p : View.PERMISSIONS.getPermissions()) {
      strategy.add(p,user)
    }
    realm = new hudson.security.HudsonPrivateSecurityRealm(false)
    // apply new strategy&realm
    if (overwrite_permissions == 'true') {
      instance.setAuthorizationStrategy(strategy)
      instance.setSecurityRealm(realm)
    }
    // commit new settings permanently (in config.xml)
    instance.save()
    // now setup s2m if requested
    if(s2m_acl == 'true') {
      enable_slave_to_master_acl(s2m_acl)
    }
  }

  ////////////////////////
  // get_num_executors
  ////////////////////////
  /*
   * Print the number of executors for the master
  */
  void get_num_executors() {
     def j = Jenkins.getInstance()
     def n = j.getNumExecutors()
     out.println(n)
  }

  ////////////////////////
  // set_num_executors
  ////////////////////////
  /*
   * Set the number of executors for the master
  */
  void set_num_executors(String n) {
     def j = Jenkins.getInstance()
     j.setNumExecutors(n.toInteger())
     j.save()
  }
} // class Actions

///////////////////////////////////////////////////////////////////////////////
// CLI Argument Processing
///////////////////////////////////////////////////////////////////////////////

def bindings = getBinding()
actions = new Actions(out, bindings)
action = args[0]
if (args.length < 2) {
  actions."$action"()
} else {
  actions."$action"(*args[1..-1])
}
