#!/usr/local/bin/php
<?php
// PukiWiki - Yet another WikiWikiWeb clone.
// $Id: encls.php,v 1.1 2006/05/14 09:24:22 henoheno Exp $
// Copyright (C) 2006 PukiWiki Developers Team
// License: GPL v2 or (at your option) any later version
//
// encoded-EUC-JP.txt -> EUC-JP -> UTF-8 -> encoded-UTF-8.txt

// PHP-cli only
if (php_sapi_name() != 'cli') die('Invalid SAPI');
if (! isset($argv)) die('PHP too old (Not 4.3.0 of above)');

$base = basename(array_shift($argv));
function usage(){
	global $base;
	echo 'Usage: ' . "\n";
	echo '    ' . $base . ' [options] file [file ...]' . "\n";
	echo '    ' . $base . ' [options] --all' . "\n";
	echo '    Options:' . "\n";
	echo '        --all            -- Check all of this directory' . "\n";
	echo '        --suffix         -- Specify suffix (default: .txt)' . "\n";
	echo '        --encoding_from  -- Specify encoding (default: EUC-JP)' . "\n";
	echo '        --encoding_to    -- Specify encoding (default: UTF-8)' . "\n";
	exit(1);
}

//////////////////////////////////
// Code from PukiWiki 1.4.7

// lib/func.php r1.72
// Encode page-name
function encode($key)
{
	return ($key == '') ? '' : strtoupper(bin2hex($key));
	// Equal to strtoupper(join('', unpack('H*0', $key)));
	// But PHP 4.3.10 says 'Warning: unpack(): Type H: outside of string in ...'
}
// Decode page name
function decode($key)
{
	return hex2bin($key);
}
// Inversion of bin2hex()
function hex2bin($hex_string)
{
	// preg_match : Avoid warning : pack(): Type H: illegal hex digit ...
	// (string)   : Always treat as string (not int etc). See BugTrack2/31
	return preg_match('/^[0-9a-f]+$/i', $hex_string) ?
	pack('H*', (string)$hex_string) : $hex_string;
}
// Remove [[ ]] (brackets)
function strip_bracket($str)
{
	$match = array();
	if (preg_match('/^\[\[(.*)\]\]$/', $str, $match)) {
		return $match[1];
	} else {
		return $str;
	}
}
//////////////////////////////////
// lib/file.php r1.68 (modified)

// Get a page list of this wiki
function get_existpages($dir = '', $ext = '.txt')
{
	$aryret = array();

	$pattern = '((?:[0-9A-F]{2})+)';
	if ($ext != '') $ext = preg_quote($ext, '/');
	$pattern = '/^' . $pattern . $ext . '$/';

	$dp = @opendir($dir) or
		die($dir . ' is not found or not readable.');
	$matches = array();
	while ($file = readdir($dp))
		if (preg_match($pattern, $file, $matches))
			$aryret[$file] = decode($matches[1]);
	closedir($dp);

	return $aryret;
}
//////////////////////////////////

if (empty($argv)) usage();

// Options
$f_all = FALSE;
$suffix = '.txt';
$encoding_from = 'EUC-JP';
$encoding_to   = 'UTF-8';
foreach ($argv as $key => $value) {
	if ($value != '' && $value[0] != '-') break;
	$optarg = '';
	list($value, $optarg) = explode('=', $value, 2);
	switch ($value) {
		case '--all'          : $f_all         = TRUE;    break;
		case '--suffix'       : $suffix        = $optarg; break;
		case '--encoding_from': $encoding_from = $optarg; break;
		case '--encoding_to'  : $encoding_to   = $optarg; break;
		case '--encoding'     : $encoding_to   = $optarg; break;
	}
	unset($argv[$key]);
}
define('SOURCE_ENCODING', $encoding_from);
define('TARGET_ENCODING', $encoding_to);

// Target
if ($f_all && empty($argv)) {
	$argv = array_keys(get_existpages('.', $suffix));
} else {
	foreach ($argv as $arg) {
		if (! file_exists($arg)) {
			echo 'File not found: ' . $arg . "\n";
			usage();
		}
	}
}

// Do
mb_internal_encoding(SOURCE_ENCODING);
mb_detect_order('auto');
$matches = array();
foreach ($argv as $arg) {
	if (preg_match('/^(.+)(\.[a-zA-Z0-9]+)$/', $arg, $matches)) {
		$name   = $matches[1];
		$suffix = $matches[2];
	} else {
		$name   = $arg;
		$suffix = '';
	}
	//echo $name . $suffix . "\n";		// As-is
	//echo decode($name) . $suffix . "\n";	// Decorded
	echo encode(mb_convert_encoding(decode($name),
		TARGET_ENCODING, SOURCE_ENCODING)) .
		$suffix . "\n";	// Decord -> convert -> encode
	//echo "\n";
}
?>
