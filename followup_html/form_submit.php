<?php
// $Id: form_submit.php,v 1.1 2007/08/28 16:33:14 henoheno Exp $
//
// Submit buttons and toggle demo
// 
// [button] prev:   off/on
// [button] write:  off/on
// [button] help:   off/on
// [button] cancel: off/on
// showhelp: off/on <= toggle with help button

$base = basename(__FILE__);

// State of buttons
$prev   = isset($_POST['prev']);
$write  = isset($_POST['write']);
$help   = isset($_POST['help']);
$cancel = isset($_POST['cancel']);

// State of status
$showhelp = isset($_POST['showhelp']) && $_POST['showhelp'] == 'on';
if ($help) $showhelp = ! $showhelp;	// Toggle

// Render
$prev     = $prev     ? 'on' : 'off';
$write    = $write    ? 'on' : 'off';
$help     = $help     ? 'on' : 'off';
$cancel   = $cancel   ? 'on' : 'off';
$showhelp = $showhelp ? 'on' : 'off';
echo <<< EOF
	[button] prev:&nbsp;&nbsp; $prev</br>
	[button] write:&nbsp;      $write</br>
	[button] help:&nbsp;&nbsp; $help</br>
	[button] cancel:           $cancel</br>
	showhelp: <strong>$showhelp</strong></br>
	<form action="$base" method="post">
		<input type="submit" name="prev"     value="Preview" />
		<input type="submit" name="write"    value="Write" />
		<input type="submit" name="help"     value="Help" />
		<input type="submit" name="cancel"   value="Cancel" />
		<input type="hidden" name="showhelp" value="$showhelp">
	</form>
EOF;
?>