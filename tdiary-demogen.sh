#!/bin/sh
# $Id: tdiary-demogen.sh,v 1.7 2005/01/25 12:47:11 henoheno Exp $
#
# tDiary demonstration generator: generates many [theme].php
# License: GPL

warn(){ echo "$*" 1>&2; }
err(){ warn "$*"; exit 1; }

usage(){
  base="`basename $0`";
  warn "  $base [-d path/to/theme-directory] list"
  warn "  $base [-d path/to/theme-directory] interwiki"
  warn "  $base [-d path/to/theme-directory] touch"
  warn "  $base [-d path/to/theme-directory] untouch"
  warn "    Command:"
  warn "      lis|list      - List themes"
  warn "      int|interwiki - Publish interwiki definition and setting for each theme"
  warn "      tou|touch     - Generate \$theme.php that includes index.php"
  warn "      unt|untouch   - Remove \$theme.php(s) listed in theme directory"
  exit 1
}

theme_list(){
  cd "$dir" || err "Error: directory '$dir' not found"
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
  echo '- (s) = sidebar CSS exists in this theme'
  theme_list | while read theme; do
    echo -n "+ [[theme:$theme]]"
    grep -q div.sidebar "$dir/$theme/$theme.css" && echo -n " (s)"
    echo
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

unt|unto|untou|untouc|untouch )
  echo -n "  Remove theme(s).php ? [y/N]: "
  read answer
  case "$answer" in
  [yY] | [yY][eE][sS] )
    theme_list | while read theme ; do
      test -f "$theme.php" && grep -q "define('TDIARY_THEME', '$theme');" "$theme.php" && rm -f "$theme.php"
    done
    ;;
  * )
    echo "  Stopped."
  esac
  ;;
esac

