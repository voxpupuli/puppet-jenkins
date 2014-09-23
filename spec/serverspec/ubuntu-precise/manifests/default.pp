
node default {
  include jenkins

  notice("Hello world from ${::hostname}}")
}
