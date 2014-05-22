<?php
/**
 * @file
 *   Legacy support for Mercurial for drush make.
 */

/**
 * Checks out a Mercurial repository to the specified download location.
 *
 * @return mixed
 *   The download location on success, FALSE otherwise.
 */
function make_download_hg($name, $download, $download_location) {
  $tmp_path = make_tmp();
  $wc = drush_get_option('working-copy');

  // check if branch option is set in info file, otherwise set default to master branch
  //  $download['branch'] = isset($download['branch']) ? $download['branch'] : 'master';

  if(isset($download['branch'])) {
    make_error('DOWNLOAD_ERROR', dt('Branches not (yet) supported in Hg downloads'));
    return false;
  }

  // check if tag option is set in info file, otherwise we set it to false
  $download['tag'] = isset($download['tag']) ? $download['tag'] : FALSE;
  // check if specific revision is set in info file
  $download['revision'] = isset($download['revision']) ? $download['revision'] : FALSE;

  $updateRevision = 'tip'; // default

  if($download['revision']) {
    if($download['tag']) {
      make_error('DOWNLOAD_ERROR', dt('tag and revision are aliases; specify at most one'));
      return false;
    }
    $updateRevision = $download['revision'];
  }
  else if ($download['tag']) {
    $updateRevision = $download['tag'];
  }

  if (!isset($download['url'])) {
    make_error('DOWNLOAD_ERROR', dt('URL is required in Hg downloads'));
    return false;
  }

  if(isset($download['submodule'])) {
    make_error('DOWNLOAD_ERROR', dt('submodule not supported in Hg downloads'));
    return false;
  }

  // split the given download url into pieces
  $url_array = array();

  // Get the protocol, site and resource parts of the URL
  // original url = http://example.com/blog/index?name=foo
  // protocol = http://
  // site = example.com/
  // resource = blog/index?name=foo
  $regex = '#^(.*?//)*(.*@)*([\w\.\d]*)(:(\d+))*(/*)(.*)$#';
  $matches = array();
  preg_match($regex, $download['url'], $matches);
  // Assign the matched parts of url to the result array
  $url_array['protocol'] = $matches[1];
  $url_array['user']     = $matches[2];
  $url_array['port']     = $matches[5];
  $url_array['host']     = $matches[3];
  $url_array['resource'] = $matches[7];

  // clean up the site portion by removing the trailing /
  $url_array['host'] = preg_replace('#/$#', '', $url_array['host']);

  // clean up the protocol portion by removing the trailing ://
  $url_array['protocol'] = preg_replace('#://$#', '', $url_array['protocol']);

  if (empty($url_array['protocol'])) {
    // If protocol is not given, assume an SSH URL.
    $url = $download['url'];
  }
  else {
    // build url for git clone to support different protocols
    // currently all protocols seems to use the same url schema
    switch ($url_array['protocol']) {
      case 'ssh':
      case 'http':
      case 'https':
        //      case 'ftp':
        //      case 'ftps':
        //      case 'rsync':
      case 'file':
        // @TODO: implement port & user options
        $url = $url_array['protocol'] .'://'. $url_array['user'] . $url_array['host'] .'/'. $url_array['resource'];
        break;

      default:
        make_error('DOWNLOAD_ERROR', dt('unknown protocol @protocol in %project', array('@protocol' => $url_array['protocol'], '%project' => $name)));
        return false;
    }
  }

  $tmp_location = drush_tempdir() . '/' . basename($download_location);

  $command = 'hg -R %s up -r %s';
  if (drush_get_context('DRUSH_VERBOSE')) {
    $command .= ' --verbose';
  }

  // clone the given repository, and update to specified tag.
  // Done in 2 steps because using hg clone -u (lowercase) fails to fail on nonexistent tags
  if (
      drush_shell_exec("hg clone -U %s %s", $url, $tmp_location) &&
      drush_shell_exec($command, $tmp_location, $updateRevision)
    ) {

    drush_log(dt('%project cloned from %url; rev %rev.', array('%project' => $name, '%url' => $url, '%rev'=> $updateRevision)), 'ok');

    //TODO Add branch / tag / rev handling here/above later (tags most likely to de needed)


    // Remove .hg/ directory if working-copy flag was not specified.
    if (!$wc && file_exists($tmp_location . '/.hg')) {
      drush_shell_exec("rm -rf %s", $tmp_location . '/.hg');
    }
    drush_shell_exec('cp -Rf %s %s', $tmp_location, dirname($download_location));
    drush_shell_exec("rm -rf %s", dirname($tmp_location));
    return dirname($tmp_location);
  } else {
    make_error('DOWNLOAD_ERROR', dt('Unable to clone %project from %url at revision/tag %rev.', array('%project' => $name, '%url' => $url, '%rev'=> $updateRevision)));
  }

  return FALSE;
}