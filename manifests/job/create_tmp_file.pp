# Define: jenkins::job::create_tmp_file
#
define jenkins::job::create_tmp_file ( config, ) {

  #
  # When a Jenkins job is imported via the cli, Jenkins will
  # re-format the xml file based on its own internal rules.
  # In order to make job management idempotent, we need to
  # apply that formatting before the import, so we can do a diff
  # on any pre-existing job to determine if an update is needed.
  #
  # Jenkins likes to change single quotes to double quotes
  $a = regsubst($config, 'version=\'1.0\' encoding=\'UTF-8\'',
                'version="1.0" encoding="UTF-8"')
  # Change empty tags into self-closing tags
  $b = regsubst($a, '<([A-z]+)><\/\1>', '<\1/>', 'IG')
  # Change &quot; to " since Jenkins is weird like that
  $c = regsubst($b, '&quot;', '"', 'MG')
  # Change &apos; to ' since Jenkins is weird like that
  $d = regsubst($c, '&apos;', '\'', 'MG')

  # Temp file to use as stdin for Jenkins CLI executable
  file { $tmp_config_path:
    content => $d,
    require => Exec['jenkins-cli'],
  }
}
