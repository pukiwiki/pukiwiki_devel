<?php
// PukiWiki - Yet another WikiWikiWeb clone.
// $Id: pkwk14.php,v 1.3 2009/01/12 02:58:07 henoheno Exp $
// Copyright (C) 2009 PukiWiki Developers Team
// License: GPL v2 or (at your option) any later version
//
// PukiWiki administration script for CLI environment


# Name and Usage --------------------------------------------
define('PKWK_CLI_NAME', $argv[0]);

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

function load($filepath)
{
	if (strpos($filepath, ':') !== FALSE) {
		err('load: Error: URL-like string');
	} else if (! file_exists($filepath)) {
		err('load: Error: No such file: ' . $filepath);
	}

	require_once($filepath);
}


# Default variables -----------------------------------------

// PKWK_ROOT
if (isset($_ENV['PKWK_ROOT'])) {
	$pkwk_root = rtrim($_ENV['PKWK_ROOT'], '/') . '/';
	if (! file_exists($pkwk_root)) {
		err('Error: [PKWK_ROOT] No such directory: ' . $pkwk_root);
	}
	
} else {
	$pkwk_root = './';
}
define('PKWK_ROOT', $pkwk_root);
unset($pkwk_root);

// LIB_DIR
define('LIB_DIR', PKWK_ROOT . 'lib/');

// DATA_HOME
define('DATA_HOME', './');
// Where to
//   * pukiwiki.ini.php


# Load libraries --------------------------------------------
// From pukiwiki.php

load(LIB_DIR . 'func.php');
load(LIB_DIR . 'file.php');
load(LIB_DIR . 'html.php');
load(LIB_DIR . 'backup.php');

load(LIB_DIR . 'convert_html.php');
load(LIB_DIR . 'make_link.php');
load(LIB_DIR . 'diff.php');
load(LIB_DIR . 'config.php');
load(LIB_DIR . 'link.php');
load(LIB_DIR . 'auth.php');
load(LIB_DIR . 'proxy.php');
if (! extension_loaded('mbstring')) {
	load(LIB_DIR . 'mbstring.php');
}

load(LIB_DIR . 'mail.php');
load(LIB_DIR . 'spam.php');


# Default variables 2 ---------------------------------------
// From pukiwiki.ini.php

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
