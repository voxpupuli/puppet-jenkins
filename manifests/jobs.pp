# Class: jenkins::jobs
#
class jenkins::jobs {

  if $caller_module_name != $module_name {
    fail("Use of private class ${name} by ${caller_module_name}")
  }

  create_resources('jenkins::job',$::jenkins::job_hash)

}
