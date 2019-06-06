# Class: jenkins::jobs
#
class jenkins::jobs {
  assert_private()

  create_resources('jenkins::job',$::jenkins::job_hash)

}
