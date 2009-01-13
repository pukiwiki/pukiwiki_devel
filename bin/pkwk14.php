<?php
// PukiWiki - Yet another WikiWikiWeb clone.
// $Id: pkwk14.php,v 1.6 2009/01/13 15:06:18 henoheno Exp $
// Copyright (C) 2009 PukiWiki Developers Team
// License: GPL v2 or (at your option) any later version
//
// PukiWiki administration script for CLI environment


# Name and Usage --------------------------------------------
define('PKWK_CLI_NAME', $argv[0]);
//define('PKWK_CLI_PATH', rtrim(getcwd(), '/\\'));

function usage()
{
	warn('Usage: PKWK_ROOT=path/to/pukiwiki php ' . PKWK_CLI_NAME);
	exit(1);
}

# Safety ----------------------------------------------------
if (php_sapi_name() != 'cli') {
	echo 'pkwk: Error: Seems not CLI';
	exit;
}

# Error reporting -------------------------------------------

//error_reporting(0); // Nothing
//error_reporting(E_ERROR | E_PARSE); // Avoid E_WARNING, E_NOTICE, etc
error_reporting(E_ALL); // Debug purpose

# Common functions ------------------------------------------
function warn($string = ''){ fwrite(STDERR, $string . "\n"); }
function err( $string = ''){ warn($string); exit(1);  }

function load_once($filepath)
{
	if (strpos($filepath, ':') !== FALSE) {
		err('load: Error: URL-like string');
	}

	require_once($filepath);
}


# Environment variables -------------------------------------

$env_default => array(
	// ENVIRONMENT     => DEFAULT
	'PKWK_ROOT'        => '.',
	'PKWK_LIB_DIR',    => 'lib',
	'PKWK_PLUGIN_DIR', => 'plugin',
	'PKWK_SKIN_DIR',   => 'skin',
	'PKWK_IMAGE_DIR',  => 'image',
	'PKWK_DATA_HOME'   => '.',
);

foreach(array_keys($env_default as $key) {
	if (isset($_ENV[$key])) {
		$env_default[$key] = rtrim($_ENV[$key], '/\\') . '/';
	}
}


//		if (! file_exists($dirs[$key])) {
//			err('Error: [' . $key . ] No such directory: ' . $dirs[$key]);
//		}


# Load libraries --------------------------------------------

define('LIB_DIR', $env['PKWK_ROOT'] . '/' . $env['PKWK_LIB_DIR'] . '/');
if (! file_exists(LIB_DIR)) {
	err('Error: LIB_DIR not found: ' . LIB_DIR);
}

load_once(LIB_DIR . 'func.php');
load_once(LIB_DIR . 'file.php');
load_once(LIB_DIR . 'html.php');
load_once(LIB_DIR . 'backup.php');

load_once(LIB_DIR . 'convert_html.php');
load_once(LIB_DIR . 'make_link.php');
load_once(LIB_DIR . 'diff.php');
load_once(LIB_DIR . 'config.php');
load_once(LIB_DIR . 'link.php');
load_once(LIB_DIR . 'auth.php');
load_once(LIB_DIR . 'proxy.php');
if (! extension_loaded('mbstring')) {
	load_once(LIB_DIR . 'mbstring.php');
}

load_once(LIB_DIR . 'mail.php');
load_once(LIB_DIR . 'spam.php');


# Default variables 2 ---------------------------------------

define('DATA_HOME', './');
// Where to
//   * pukiwiki.ini.php
//   * xxx_DIR

if (! defined('LANG'))    define('LANG',    'ja');
if (! defined('UI_LANG')) define('UI_LANG', LANG);

if (! defined('DATA_DIR'))    define('DATA_DIR',      DATA_HOME . 'wiki/'     );
if (! defined('DIFF_DIR'))    define('DIFF_DIR',      DATA_HOME . 'diff/'     );
if (! defined('BACKUP_DIR'))  define('BACKUP_DIR',    DATA_HOME . 'backup/'   );
if (! defined('CACHE_DIR'))   define('CACHE_DIR',     DATA_HOME . 'cache/'    );
if (! defined('UPLOAD_DIR'))  define('UPLOAD_DIR',    DATA_HOME . 'attach/'   );
if (! defined('COUNTER_DIR')) define('COUNTER_DIR',   DATA_HOME . 'counter/'  );
if (! defined('PLUGIN_DIR'))  define('PLUGIN_DIR',    DATA_HOME . 'plugin/'   );

if (! defined('SKIN_DIR')) define('SKIN_DIR', 'skin/');
if (! defined('IMAGE_DIR')) define('IMAGE_DIR', 'image/');

switch (LANG) {
case 'ja':
	if (! defined('ZONE'))     define('ZONE', 'JST');
	if (! defined('ZONETIME')) define('ZONETIME', 9 * 3600); // JST = GMT + 9
	break;
default  :
	if (! defined('ZONE'))     define('ZONE', 'GMT');
	if (! defined('ZONETIME')) define('ZONETIME', 0);
	break;
}

//$script = 'http://localhost.example.org/';

# Load libraries --------------------------------------------
// init.php now fails

// Load *.ini.php files and init PukiWiki
//require(LIB_DIR . 'init.php');


# Start -----------------------------------------------------

usage();

?>
