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
import com.cloudbees.plugins.credentials.*
import com.cloudbees.plugins.credentials.common.*
import com.cloudbees.plugins.credentials.domains.*
import com.cloudbees.plugins.credentials.impl.*
import groovy.transform.InheritConstructors
import hudson.model.*
import hudson.plugins.sshslaves.*
import hudson.util.*
import jenkins.model.*
import jenkins.security.*
import org.apache.commons.io.IOUtils
import org.jenkinsci.plugins.*

class InvalidAuthenticationStrategy extends Exception{}
@InheritConstructors
class UnsupportedCredentialsClass extends Exception {}
@InheritConstructors
class InvalidCredentialsId extends Exception {}
@InheritConstructors
class MissingRequiredPlugin extends Exception {}

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

  def findCredentialsById(String id, Domain domain=Domain.global()) {
    def idMatcher = CredentialsMatchers.withId(id)
    def credStore = Jenkins.getInstance().getExtensionList(
      'com.cloudbees.plugins.credentials.SystemCredentialsProvider'
    )[0].getStore()
    def allCreds = credStore.getCredentials(domain)

    return CredentialsMatchers.firstOrNull(allCreds, idMatcher)
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

  def findAndInvokeConstructor(Class c, List args) {
    // groovy.json parses JSON Booleans as java.lang.Boolean objects. It also
    // appears to be impossible in Groovy convert or cast to a primitive
    // boolean.  Groovy correctly auto-unboxes Booleans for Java methods
    // with boolean parameters but the exact type name is required to find the
    // constructor signature.

    def ctor

    // if we have a null arg, we don't know how to map that back to a class
    // (hooray for java) and Class::getDeclaredConstructor() will fail. We are
    // being lazy here and trying to match only by the number of arguments.
    //
    // A better implementation would try to compare parameter types with null
    // matching any class that is an instance of Object
    if (args.any { it == null }) {
      def ctors = c.getDeclaredConstructors()

      def nArgs = args.size()
      ctor = ctors.find {
        nArgs == it.getParameterTypes().size()
      }

      if (ctor == null) {
        throw new NoSuchMethodException(
          "no constructor found for class: " + c + " with args: " + args
        )
      }
    } else {
      // XXX explicit type declaration is required here
      def Class[] signature = args.collect {
        it instanceof Boolean ? boolean.class : it.class
      }

      ctor = c.getDeclaredConstructor(signature)
    }

    // special case the null realm/strategy singletons with private
    // constructors
    switch (c) {
      case hudson.security.SecurityRealm$None:
      case hudson.security.AuthorizationStrategy$Unsecured:
        ctor.setAccessible(true);
        break
    }

    ctor.newInstance(*args)
  }

  def findSuperClasses(Class c) {
    def classList = []
    def superclass = c
    while (superclass != Object) {
      classList.add(superclass)
      try {
        superclass = superclass.getSuperclass()
      } catch (MissingPropertyException e) {
        break
      }
    }

    classList
  }

  def Map findJobs(Object obj, String namespace = null) {
    def found = [:]

    // groovy apparently can't #collect on a list and return a map?
    obj.items.each { job ->
      // a possibly better approach would be to walk the parent chain from //
      // each job
      def path = job.getName()
      if (namespace) {
        path = "${namespace}/" + path
      }

      found[path] = job

      // intentionally not using `instanceof` here so we don't blow up if the
      // cloudbees-folder plugin is not installed
      if (job.getClass().getName() == 'com.cloudbees.hudson.plugins.folder.Folder') {
        found << findJobs(job, path)
      }
    }

    found
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
  // create or update user from JSON
  /////////////////////////
  void user_update() { // or create
    // parse JSON doc from stdin
    def slurper = new groovy.json.JsonSlurper()
    def text = bindings.stdin.text
    def conf = slurper.parseText(text)

    // a user id is required
    def id = conf['id']
    assert id != null
    assert id instanceof String
    def user = hudson.model.User.get(id)

    def full_name = conf['full_name']
    if (full_name) {
      assert full_name instanceof String
      user.setFullName(full_name)
    }

    def email_address = conf['email_address']
    if (email_address) {
      assert email_address instanceof String
      def email_param = new hudson.tasks.Mailer.UserProperty(email_address)
      user.addProperty(email_param)
    }

    // it is not possible to directly set the API token because the user
    // visible value is actually a digest of the "plain text" token after it
    // is unencrypted.
    def api_token_plain = conf['api_token_plain']
    if (api_token_plain) {
      assert api_token_plain instanceof String
      def token_param = new ApiTokenProperty()
      token_param.@apiToken = new Secret(api_token_plain)
      user.addProperty(token_param)
    }

    if (conf['api_token_public'] != null) {
      bindings.stderr.println('ignoring api_token_public - it is not possible to set the API token directly')
    }

    def public_keys = conf['public_keys']
    if (public_keys) {
      assert public_keys instanceof List
      // convert list of keys into a single string
      def keys = public_keys.join("\n")
      def keys_param = new org.jenkinsci.main.modules.cli.auth.ssh.UserPropertyImpl(keys)
      user.addProperty(keys_param)
    }

    def password = conf['password']
    if (password) {
      // per https://github.com/jenkinsci/jenkins/blob/master/core/src/main/java/hudson/security/HudsonPrivateSecurityRealm.java#L673-L692
      // if it has the JBCRYPT_HEADER, we assume it's a hashed password,
      // otherwise treat it as plain text
      def password_param
      if (password =~ /^#jbcrypt:/) {
        password_param = hudson.security.HudsonPrivateSecurityRealm.Details.fromHashedPassword(password)
      } else {
        password_param = hudson.security.HudsonPrivateSecurityRealm.Details.fromPlainPassword(password)
      }

      user.addProperty(password_param)
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
  // list all current users as JSON
  /////////////////////////
  void user_info_all() {
    def allUsers = hudson.model.User.getAll()

    def allInfo = []
    allUsers.each { user ->
      def info = util.userToMap(user)
      allInfo.add(info)
    }

    def builder = new groovy.json.JsonBuilder(allInfo)

    out.println(builder.toPrettyString())
  }

  /////////////////////////
  // create credentials
  /////////////////////////
  void create_or_update_credentials(String username, String password, String id="", String description="", String private_key="") {
    def global_domain = Domain.global()
    def credentials_store =
      Jenkins.instance.getExtensionList(
        'com.cloudbees.plugins.credentials.SystemCredentialsProvider'
      )[0].getStore()

    def credentials
    if (id == "") {
      id = null
    }
    if (private_key == "" ) {
      credentials = new UsernamePasswordCredentialsImpl(
        CredentialsScope.GLOBAL,
        id,
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
        id,
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

  ////////////////////////
  // credentials_list_json
  ////////////////////////
  /*
   * list all credentials in the `global` domain as a JSON document to the
   * stdout
  */
  void credentials_list_json() {
    def j = Jenkins.getInstance()

    def credentialsStore = j.getExtensionList(
      'com.cloudbees.plugins.credentials.SystemCredentialsProvider'
    )[0].getStore()

    // XXX intentionally ignoring all domains except for global/null
    def domain = Domain.global()

    // UnmodifiableRandomAccessList with all credentials in the domain.
    // BaseCredentials objects do not appear to know what domain they are part
    // of so we need to keep track of which domain a credentials was retrieved
    // from.
    def allCreds = credentialsStore.getCredentials(domain)

    def allInfo = []

    // note that id is theoretically unique for a credential across all domains
    allCreds.each { cred ->
      def info = [
        id:     cred.id,
        domain: domain.getName(),
        scope:  cred.scope,
        impl:  cred.class.getSimpleName(),
      ]

      switch (cred) {
        case com.cloudbees.plugins.credentials.impl.UsernamePasswordCredentialsImpl:
          info['description'] = cred.description
          info['username'] = cred.username
          info['password'] = cred.password.plainText
          break
        case com.cloudbees.jenkins.plugins.sshcredentials.impl.BasicSSHUserPrivateKey:
          info['description'] = cred.description
          info['username'] = cred.username
          info['private_key'] = cred.privateKey
          info['passphrase'] = cred.passphrase.plainText
          break
        case org.jenkinsci.plugins.plaincredentials.impl.StringCredentialsImpl:
          info['description'] = cred.description
          info['secret'] = cred.secret.plainText
          break
        case org.jenkinsci.plugins.plaincredentials.impl.FileCredentialsImpl:
          info['description'] = cred.description
          info['file_name'] = cred.getFileName()
          info['content'] = IOUtils.toString(cred.getContent(), "UTF-8")
          break
        case com.cloudbees.plugins.credentials.impl.CertificateCredentialsImpl:
          def keyStoreSource = cred.getKeyStoreSource()

          info['description'] = cred.description
          info['password'] = cred.password.plainText
          info['password_empty'] = cred.passwordEmpty
          info['key_store_impl'] = keyStoreSource.class.getSimpleName()

          switch (keyStoreSource) {
            case com.cloudbees.plugins.credentials.impl.CertificateCredentialsImpl$UploadedKeyStoreSource:
              info['content'] = IOUtils.toString(keyStoreSource.getKeyStoreBytes(), "UTF-8")
              break
            case com.cloudbees.plugins.credentials.impl.CertificateCredentialsImpl$FileOnMasterKeyStoreSource:
              info['source'] = keyStoreSource.getKeyStoreFile()
              break
            default:
              throw new UnsupportedCredentialsClass("unsupported " + keyStoreSource)
          }
          break
        default:
          throw new UnsupportedCredentialsClass("unsupported " + cred)
      }

      allInfo.add(info)
    }

    def builder = new groovy.json.JsonBuilder(allInfo)
    out.println(builder.toPrettyString())
  }

  ////////////////////////
  // credentials_update_json
  ////////////////////////
  /*
   * modify an existing credentials specified by a JSON document passed via
   * the stdin
  */
  void credentials_update_json() {
    def j = Jenkins.getInstance()

    // parse JSON doc from stdin
    def slurper = new groovy.json.JsonSlurper()
    def text = bindings.stdin.text
    def conf = slurper.parseText(text)

    def cred = null
    switch (conf['impl']) {
      case 'UsernamePasswordCredentialsImpl':
        cred = new UsernamePasswordCredentialsImpl(
          // CredentialsScope is an enum
          CredentialsScope."${conf['scope']}",
          conf['id'],
          conf['description'],
          conf['username'],
          conf['password']
        )
        break
      case 'BasicSSHUserPrivateKey':
        def key = new BasicSSHUserPrivateKey.DirectEntryPrivateKeySource(
          conf['private_key']
        )
        cred = new BasicSSHUserPrivateKey(
          // CredentialsScope is an enum
          CredentialsScope."${conf['scope']}",
          conf['id'],
          conf['username'],
          key,
          conf['passphrase'],
          conf['description']
        )
        break
      case 'StringCredentialsImpl':
        if (! j.getPlugin('plain-credentials')) {
          throw new MissingRequiredPlugin('plain-credentials')
        }

        // we can not declare:
        // import org.jenkinsci.plugins.plaincredentials.impl.*
        // if plain-credentials is not present
        cred = this.class.classLoader.loadClass('org.jenkinsci.plugins.plaincredentials.impl.StringCredentialsImpl').newInstance(
          // CredentialsScope is an enum
          CredentialsScope."${conf['scope']}",
          conf['id'],
          conf['description'],
          new Secret(conf['secret'])
        )
        break
      default:
        throw new UnsupportedCredentialsClass("unsupported " + conf['impl'])
    }
    assert cred != null

    def domain = Domain.global()
    def existingCred = util.findCredentialsById(conf['id'], domain)
    def credStore = j.getExtensionList(
      'com.cloudbees.plugins.credentials.SystemCredentialsProvider'
    )[0].getStore()
    assert credStore != null

    if (existingCred != null) {
      credStore.updateCredentials(domain, existingCred, cred)
    } else {
      credStore.addCredentials(domain, cred)
    }
  }

  //////////////////////////
  // delete credentials by id
  //////////////////////////
  /*
   * remove a credentials by `id`
  */
  void credentials_delete_id(String id) {
    def j = Jenkins.getInstance()

    def domain = Domain.global()
    def existingCred = util.findCredentialsById(id, domain)

    if (existingCred != null) {
      def credStore = j.getExtensionList(
        'com.cloudbees.plugins.credentials.SystemCredentialsProvider'
      )[0].getStore()

      credStore.removeCredentials(domain, existingCred)
    } else {
      throw new InvalidCredentialsId("invalid credentials id: $id")
    }
  }

  ////////////////////////
  // set_security
  ////////////////////////
  /*
   * Set up security for the Jenkins instance. This currently supports
   * only a small number of configurations. If authentication is enabled, it
   * uses the internal user database.
  */
  void set_security(String security_model) {
    def j = Jenkins.getInstance()

    if (security_model == 'disabled') {
      j.disableSecurity()
      return null
    }

    def strategy
    def realm
    switch (security_model) {
      case 'full_control':
        strategy = new hudson.security.FullControlOnceLoggedInAuthorizationStrategy()
        realm = new hudson.security.HudsonPrivateSecurityRealm(false, false, null)
        break
      case 'unsecured':
        strategy = new hudson.security.AuthorizationStrategy.Unsecured()
        realm = new hudson.security.HudsonPrivateSecurityRealm(false, false, null)
        break
      default:
        throw new InvalidAuthenticationStrategy()
    }
    j.setAuthorizationStrategy(strategy)
    j.setSecurityRealm(realm)
    j.save()
  }

  void get_security_realm() {
    def j = Jenkins.getInstance()
    def realm = j.getSecurityRealm()

    def className = realm.getClass().getName()
    def config
    switch (className) {
      // "Jenkins’ own user database"
      case 'hudson.security.HudsonPrivateSecurityRealm':
        config = [
          setSecurityRealm: [
            (className): [
              realm.allowsSignup(),
              realm.isEnableCaptcha(),
              null,
            ],
          ],
        ]
        break

      // "Unix user/group database"
      case 'hudson.security.PAMSecurityRealm':
        config = [
          setSecurityRealm: [
            (className): [
              // there is no accessor for the serviceName field
              realm.@serviceName
            ],
          ],
        ]
        break

      // XXX not implemented "LDAP"
      //case hudson.security.LDAPSecurityRealm:
      // public LDAPSecurityRealm(String server, String rootDN, String userSearchBase, String userSearch, String groupSearchBase, String groupSearchFilter, LDAPGroupMembershipStrategy groupMembershipStrategy, String managerDN, Secret managerPasswordSecret, boolean inhibitInferRootDN, boolean disableMailAddressResolver, CacheConfiguration cache, EnvironmentProperty[] environmentProperties, String displayNameAttributeName, String mailAddressAttributeName, IdStrategy userIdStrategy, IdStrategy groupIdStrategy)

      // github-oauth
      case 'org.jenkinsci.plugins.GithubSecurityRealm':
        config = [
          setSecurityRealm: [
            (className): [
              realm.getGithubWebUri(),
              realm.getGithubApiUri(),
              realm.getClientID(),
              realm.getClientSecret(),
              realm.getOauthScopes(),
            ],
          ],
        ]
        break

      //  active directory
      case 'hudson.plugins.active_directory.ActiveDirectorySecurityRealm':
        config = [
          setSecurityRealm: [
            (className): [
              realm.domain,
              realm.site,
              realm.bindName,
              realm.bindPassword,
              realm.server,
            ],
          ],
        ]
        break

      // constructor with no arguments
      // "Delegate to servlet container"
      case 'hudson.security.LegacySecurityRealm':
      default:
        config = [
          setSecurityRealm: [
            (realm.getClass().getName()): [],
         ],
       ]
    }

    def builder = new groovy.json.JsonBuilder(config)

    out.println(builder.toPrettyString())
  }

  ////////////////////////
  // get_authorization_strategy
  ////////////////////////
  void get_authorization_strategy() {
    def j = Jenkins.getInstance()
    def strategy = j.getAuthorizationStrategy()

    def className = strategy.getClass().getName()
    def config
    switch (strategy) {
      // github-oauth
      case 'org.jenkinsci.plugins.GithubAuthorizationStrategy':
        config = [
          setAuthorizationStrategy: [
            (className): [
              strategy.adminUserNames,
              strategy.authenticatedUserReadPermission,
              strategy.useRepositoryPermissions,
              strategy.authenticatedUserCreateJobPermission,
              strategy.organizationNames,
              strategy.allowGithubWebHookPermission,
              strategy.allowCcTrayPermission,
              strategy.allowAnonymousReadPermission,
            ],
          ],
        ]
        break

      // constructor with no arguments
      // "Anyone can do anything"
      case 'hudson.security.AuthorizationStrategy$Unsecured':
      // "Legacy mode"
      case 'hudson.security.LegacyAuthorizationStrategy':
      // "Logged-in users can do anything"
      case 'hudson.security.FullControlOnceLoggedInAuthorizationStrategy':
      // "Matrix-based security"
      case 'hudson.security.GlobalMatrixAuthorizationStrategy':
        // technically, you can select this class but it will "brick" the
        // authorization strategy without additional method calls to configure
        // the matrix which are not presently supported
      // "Project-based Matrix Authorization Strategy"
      case 'hudson.security.ProjectMatrixAuthorizationStrategy':
        // same issue as hudson.security.GlobalMatrixAuthorizationStrategy
      default:
        config = [
          setAuthorizationStrategy: [
            (className): [],
          ],
        ]
    }

    def builder = new groovy.json.JsonBuilder(config)

    out.println(builder.toPrettyString())
  }

  ////////////////////////
  // set_jenkins_instance
  ////////////////////////
  void set_jenkins_instance() {
    def j = Jenkins.getInstance()

    def setup = { info ->
      def className
      def args

      info.each { entry ->
        className = entry.key
        args      = entry.value
      }
      // #forName does not appear to work under groovy. Eg.,
      // Class c = Class.forName(className)
      def c = this.class.classLoader.loadClass(className)

      util.findAndInvokeConstructor(c, args)
    }

    // parse JSON doc from stdin
    def slurper = new groovy.json.JsonSlurper()
    def text = bindings.stdin.text
    def conf = slurper.parseText(text)

    // each key in the hash is a method on the Jenkins singleton.  The key's
    // value is an object to instantiate and pass to the method.  (currently,
    // only one parameter is supported)
    conf.each { entry ->
      def methodName = entry.key
      def args = setup(entry.value)

      // reflection (at least under groovy) does not appear to match
      // subclasses for parameter types.  Eg.,
      // org.jenkinsci.plugins.GithubSecurityRealm does not match
      // hudson.security.SecurityRealm

      // try class + superclass(es) of the parameter's type
      def classList = util.findSuperClasses(args.class)
      def status = classList.any { c ->
        try {
          def m = j.class.getMethod(methodName, c)
          m.invoke(j, args)
          true
        } catch (NoSuchMethodException e) {
          false
        }
      }

      if (!status) {
        def m = j.class.getMethods().find { it.name == methodName }
        if (m == null) {
          // see if we can find any method matching that name
          throw new NoSuchMethodException(
            "no Jenkins instance method found for: " + methodName + " with args: " + args.class
          )
        }
        m.invoke(j, args)
      }
    }

    j.save()
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

  ////////////////////////
  // get_slaveagent_port
  ////////////////////////
  /*
   * Print the port number of the slave agent
  */
  void get_slaveagent_port() {
    def j = Jenkins.getInstance()
    def n = j.getSlaveAgentPort()
    out.println(n)
  }

  ////////////////////////
  // set_slaveagent_port
  ////////////////////////
  /*
   * Set the portnumber of the slave agent
  */
  void set_slaveagent_port(String n) {
    def j = Jenkins.getInstance()
    j.setSlaveAgentPort(n.toInteger())
    j.save()
  }

  /////////////////////////
  // job_enabled
  /////////////////////////
  /*
   * Print the job's state as either "true" or "false"
  */
  void job_enabled(String name) {
    try {
      def disabled = Jenkins.getInstance().getJob(name).isDisabled()
      out.println(!disabled)
    }
    catch (MissingMethodException me) {
      out.println("Found resource is not a job, skipping.")
    }
  }

  /////////////////////////
  // job_list_json
  /////////////////////////
  /*
   * Return all the configured jobs as a list of maps
   */
  void job_list_json() {
    def jobs = util.findJobs(Jenkins.getInstance())

    def allInfo = jobs.collect { path, job ->
      // at least these job classes do not respond to respond to #isDisabled:
      // - org.jenkinsci.plugins.workflow.job.WorkflowJob
      // - com.cloudbees.hudson.plugins.folder.Folder
      def enabled = false
      if (job.metaClass.respondsTo(job, 'isDisabled')) {
        enabled = !job.isDisabled()
      }

      [
        name: path,
        config: job.getConfigFile().getFile().getText('utf-8'),
        enabled: enabled
      ]
    }

    def builder = new groovy.json.JsonBuilder(allInfo)
    out.println(builder.toPrettyString())
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
