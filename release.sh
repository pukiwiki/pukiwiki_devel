#!/bin/sh
# $Id: release.sh,v 1.14 2005/02/20 14:49:42 henoheno Exp $
# $CVSKNIT_Id: release.sh,v 1.11 2004/05/28 14:26:24 henoheno Exp $
#  Release automation script for PukiWiki
#  ==========================================================
   Copyright='(C) 2002-2004 minix-up project, All Rights Reserved'
   Homepage='http://cvsknit.sourceforge.net/'
   License='BSD Licnese, NO WARRANTY'
#

# Name and Usage --------------------------------------------
_name="` basename $0 `"

usage(){
  trace 'usage()' || return  # (DEBUG)
  warn  "Usage: $_name [options] VERSION_TAG (1.4.3_rc1 like)"
  warn  "  Options:"
  warn  "    --nopkg   Suppress creating archive (Extract and chmod only)"
  warn  "    -z|--zip  Create *.zip archive"
  return 1
}

# Common functions ------------------------------------------
warn(){  echo "$*" 1>&2 ; }
err() {  warn "Error: $*" ; exit 1 ; }

quote(){
  test    $# -gt 0  && {  echo -n  "\"$1\"" ; shift ; }
  while [ $# -gt 0 ] ; do echo -n " \"$1\"" ; shift ; done ; echo
}

trace(){
  test "$__debug" || return 0  # (DEBUG)
  _msg="$1" ; test $# -gt 0 && shift ; warn "  $_msg	: ` quote "$@" `"
}

# Default variables -----------------------------------------

mod=pukiwiki

CVSROOT=":pserver:anonymous@cvs.sourceforge.jp:/cvsroot/$mod"

# Function verifying arguments ------------------------------

getopt(){ _arg=noarg
  trace 'getopt()' "$@"  # (DEBUG)

  case "$1" in
  ''  )  echo 1 ;;
  -[hH]|--help ) echo _help _exit ;;
  --debug      ) echo _debug      ;;
  --nopkg      ) echo _nopkg      ;;
  -z|--zip     ) echo _zip        ;;
  -d  ) echo _CVSROOT 2 ; _arg="$2" ;;
  -*  ) warn "Error: Unknown option \"$1\"" ; return 1 ;;
   *  ) echo OTHER ;;
  esac

  test 'x' != "x$_arg"
}

# Working start ---------------------------------------------

# Show arguments in one line (DEBUG)
case '--debug' in "$1"|"$3") false ;; * ) true ;; esac || {
  test 'x--debug' = "x$1" && shift ; __debug=on ; trace 'Args  ' "$@"
}

# Parsing
while [ $# -gt 0 ] ; do
  chs="` getopt "$@" `" || err "Syntax error with '$1'"
  trace '$chs  ' "$chs"  # (DEBUG)

  for ch in $chs ; do
    case "$ch" in
     [1-3]   ) shift $ch ;;
     _exit   ) exit      ;;
     _help   ) usage     ;;

     _CVSROOT) CVSROOT="$2" ;;

     _*      ) shift ; eval "_$ch"=on ;;
      *      ) break 2   ;;
    esac
  done
done

# No argument
if [ $# -eq 0 ] ; then usage ; exit ; fi

# Archiver check --------------------------------------------

if [ -z "$__zip" ]
then
  which tar  || err "tar not found"
  which gzip || err "gzip not found"
else
  which zip  || err "zip not found"
fi > /dev/null

# Argument check --------------------------------------------

rel="$1"
pkg_dir="${mod}-${rel}"
case "$rel" in
  [1-9].[0-9]              | [1-9].[0-9]                   ) tag="r$rel" ;;
  [1-9].[0-9]_rc[1-9]      | [1-9].[0-9]_rc[1-9]           ) tag="r$rel" ;;
  [1-9].[0-9].[0-9]        | [1-9].[0-9].[0-9][0-9]        ) tag="r$rel" ;;
  [1-9].[0-9].[0-9]_[a-z]* | [1-9].[0-9].[0-9][0-9]_[a-z]* ) tag="r$rel" ;;
  [1-9].[0-9].[0-9]_[0-9]  | [1-9].[0-9].[0-9][0-9]_[0-9]  ) tag="r$rel" ;;
  HEAD | r1_3_3_branch ) tag="$rel" ;;
  * ) usage ; exit ;;
esac
tag="` echo "$tag" | tr '.' '_' `"

# Export the module -----------------------------------------

test ! -d "$pkg_dir" || err "There's already a directory: $pkg_dir"

echo cvs -z3 -d "$CVSROOT" -q export -r "$tag" -d "$pkg_dir" "$mod"
     cvs -z3 -d "$CVSROOT" -q export -r "$tag" -d "$pkg_dir" "$mod"

test   -d "$pkg_dir" || err "There is'nt a directory: $pkg_dir"

# Remove '.cvsignore' if exists -----------------------------
echo find "$pkg_dir" -type f -name '.cvsignore' -delete
     find "$pkg_dir" -type f -name '.cvsignore' -delete

# chmod -----------------------------------------------------
( cd "$pkg_dir"

  # ALL: Read only
  find . -type d | while read line; do
      chmod 755 "$line"
    done
  find . -type f | while read line; do
      chmod 644 "$line"
    done

  # Add write permission for PukiWiki
  chmod 777 attach backup cache counter diff trackback wiki*
  chmod 666 wiki*/*.txt cache/*.dat cache/*.ref cache/*.rel
)

# Create a package ------------------------------------------

test ! -z "$__nopkg" && exit 0

( cd "$pkg_dir"

  # wiki.en/
  target="wiki.en"
  if [ -z "$__zip" ]
  then tar cf - "$target" | gzip -9 > "$target".tgz
  else zip -r9 "$target.zip" "$target"
  fi
  rm -Rf "$target"

  # en documents
  if [ -z "$__zip" ]
  then gzip -9 *.en.txt
  else
    for list in *.en.txt ; do
      zip  -9 "$list".zip "$list"
      rm -f "$list"
    done
  fi
)

if [ -z "$__zip" ]
then
  # Tar + gzip
  echo tar cf - "$pkg_dir" \| gzip -9 \> "$pkg_dir.tar.gz"
       tar cf - "$pkg_dir"  | gzip -9  > "$pkg_dir.tar.gz"
else
  # Zip
  echo zip -r9 "$pkg_dir.zip" "$pkg_dir"
       zip -r9 "$pkg_dir.zip" "$pkg_dir"
fi

