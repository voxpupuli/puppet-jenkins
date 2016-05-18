# Class: jenkins::plugins
#
class jenkins::plugins {

  if $caller_module_name != $module_name {
    fail("Use of private class ${name} by ${caller_module_name}")
  }

   $plugin_dir      = "${jenkins::params::libdir}/plugins"
   
   create_resources('jenkins::plugin',$jenkins::plugin_hash)
  
}
