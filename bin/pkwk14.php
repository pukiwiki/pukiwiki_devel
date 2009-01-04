<?php
// PukiWiki - Yet another WikiWikiWeb clone.
// $Id: pkwk14.php,v 1.1 2009/01/04 10:51:30 henoheno Exp $
// Copyright (C) 2009 PukiWiki Developers Team
// License: GPL v2 or (at your option) any later version
//
// PukiWiki administration script

// Error reporting
//error_reporting(0); // Nothing
error_reporting(E_ERROR | E_PARSE); // Avoid E_WARNING, E_NOTICE, etc
//error_reporting(E_ALL); // Debug purpose


# Safety ----------------------------------------------------
if (php_sapi_name() != 'cli') {
	echo 'pkwk: Error: Seems not CLI';
	exit;
}

# Name and Usage --------------------------------------------
define('PKWK_CLI_NAME', $argv[0]);

function usage()
{
	warn('Usage: ' . PKWK_CLI_NAME);
	exit(1);
}

# Common functions ------------------------------------------
function warn($string = ''){ fwrite(STDERR, $string . "\n"); }
function err( $string = ''){ warn($string); exit(1);  }

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

require(LIB_DIR . 'func.php');
require(LIB_DIR . 'file.php');
require(LIB_DIR . 'html.php');
require(LIB_DIR . 'backup.php');

require(LIB_DIR . 'convert_html.php');
require(LIB_DIR . 'make_link.php');
require(LIB_DIR . 'diff.php');
require(LIB_DIR . 'config.php');
require(LIB_DIR . 'link.php');
require(LIB_DIR . 'auth.php');
require(LIB_DIR . 'proxy.php');
if (! extension_loaded('mbstring')) {
	require(LIB_DIR . 'mbstring.php');
}

require(LIB_DIR . 'mail.php');
require(LIB_DIR . 'spam.php');


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


# Load libraries --------------------------------------------

exit(0);

?>
