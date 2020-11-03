# @summary Create Jenkins Jobs
# @api private
class jenkins::jobs {
  assert_private()

  create_resources('jenkins::job', $jenkins::job_hash)
}
