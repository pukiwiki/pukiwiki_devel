#!/bin/sh
# $Id: tdiary-demogen.sh,v 1.1 2005/01/09 04:07:04 henoheno Exp $
#
# tDiary demonstrator generator
# License: GPL

usage(){
  base="`basename $0`";
  echo "  $base [-d path/to/theme-directory] list"
  echo "  $base [-d path/to/theme-directory] interwiki [URI]"
  echo "  $base [-d path/to/theme-directory] touch"
  echo "    Command:"
  echo "      lis|listt     - List theme"
  echo "      int|interwiki - Publish interwiki definition and setting for each theme"
  echo "      tou|touch     - Generate \$theme.php that includes index.php"
}

theme_list(){
  cd "$dir" || echo "Error: directory '$dir' not found";
  ls -1 | while read theme; do
    test -f "$theme/$theme.css" && echo "$theme"
  done
}

# ---- Argument check ----
dir="skin/theme"
if [ "x-d" = "x$1" ] ; then
  dir="$2"
  shift 2
fi
cmd="$1"

# ----

case "$cmd" in
''|-h|hel|help ) usage ;;
lis|list       ) theme_list ;;

int|inte|inter|interw|interwi|interwik|interwiki)
  echo '--------'
  echo '- [./$1.php theme] raw tDiary theme selector'
  echo '--------'
  theme_list | while read theme; do
    echo "[[theme:$theme]]"
  done
  ;;

tou|touc|touch )
  theme_list | while read theme; do
    if [ -f "$theme.php" ]
    then echo "Warning: '$theme.php' is already available. Ignoreing..."
    else
      cat <<EOF  > "$theme.php"
<?php
	define('TDIARY_THEME', '$theme');
	require('./index.php')
?>
EOF
    fi
  done
  ;;
esac

