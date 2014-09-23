
node default {
  class {
    'jenkins':
      cli => true,
  }

  notice("Hello world from ${::hostname}}")
}
