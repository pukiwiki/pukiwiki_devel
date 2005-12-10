#!/bin/sh
# $Id: release_update.sh,v 1.12 2005/12/10 08:27:00 henoheno Exp $
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
  warn "USAGE: $_name [options] VERSION_FROM VERSION_TO (VERSION = '1.4.3_rc1' like)"
  warn "  Options:"
  warn  "    -p|--patch  Create a large patch file"
  warn  "    -z|--zip    Create *.zip archive"
  warn  "    --move-dist Move *.ini.php => *.ini-dist.php"
  warn  "    --copy-dist Move, and Copy *.ini.php <= *.ini-dist.php"
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

check_versiontag(){
  case "$1" in
    [1-9].[0-9]              | [1-9].[0-9]                   ) tag="r$1" ;;
    [1-9].[0-9]_rc[1-9]      | [1-9].[0-9]_rc[1-9]           ) tag="r$1" ;;
    [1-9].[0-9].[0-9]        | [1-9].[0-9].[0-9][0-9]        ) tag="r$1" ;;
    [1-9].[0-9].[0-9]_[a-z]* | [1-9].[0-9].[0-9][0-9]_[a-z]* ) tag="r$1" ;;
    [1-9].[0-9].[0-9]_[1-9]  | [1-9].[0-9].[0-9][0-9]_[1-9]  ) tag="r$1" ;;
    HEAD | r1_3_3_branch ) tag="$rel" ;;
    '' ) usage ; return 1 ;;
     * ) warn "Error: Invalid string: $1" ; usage ; return 1 ;;
  esac
  echo "$tag" | tr '.' '_'
}

chmod_pkg(){
  ( cd "$1"
    # ALL: Read only
    find . -type d | while read line; do chmod 755 "$line"; done
    find . -type f | while read line; do chmod 644 "$line"; done
    # Add write permission for PukiWiki
    chmod 777 attach backup cache counter diff trackback wiki* 2>/dev/null
    chmod 666 wiki*/*.txt cache/*.dat cache/*.ref cache/*.rel  2>/dev/null
  )
}

# Default variables -----------------------------------------

mod=pukiwiki
CVSROOT=":pserver:anonymous@cvs.sourceforge.jp:/cvsroot/$mod"

pkg_dir="$mod"

# Function verifying arguments ------------------------------

getopt(){ _arg=noarg
  trace 'getopt()' "$@"  # (DEBUG)

  case "$1" in
  ''  )  echo 1 ;;
  -[hH]|--help ) echo _help _exit ;;
  --debug      ) echo _debug      ;;
  -p|--patch   ) echo _patch      ;;
  -z|--zip     ) echo _zip        ;;
  --copy-dist  ) echo _copy_dist  ;;
  --move-dist  ) echo _move_dist  ;;
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

# Argument check --------------------------------------------

rel_from="$1"
rel_to="$2"
if [ "x$rel_from" = "x$rel_to" ] ; then
  warn "Error: VERSION_FROM and VERSION_TO is equivalent"
  usage ; exit
fi

tag_from="` check_versiontag "$rel_from" `" || exit
tag_to="`   check_versiontag "$rel_to"   `" || exit

# -----------------------------------------------------------

# Creating a PATCH
test "$__patch" && {
  file="${mod}-${tag_from}-${tag_to}.diff.gz"
  test ! -f "$file" || err "There's already a file: $file"

  echo $file
  echo cvs -z3 -d "$CVSROOT" rdiff -u -r "$tag_from" -r "$tag_to" "$mod"
       cvs -z3 -d "$CVSROOT" rdiff -u -r "$tag_from" -r "$tag_to" "$mod" | gzip -9 > "$file"
  exit
}
# NOT PATCH


# Checkout the module with VERSION_FROM
test ! -d "$pkg_dir" || err "There's already a directory: $pkg_dir"
echo cvs -z3 -d "$CVSROOT" co -r "$tag_from" -d "$pkg_dir" "$mod"
     cvs -z3 -d "$CVSROOT" co -r "$tag_from" -d "$pkg_dir" "$mod"
test   -d "$pkg_dir" || err "There isn't a directory: $pkg_dir"


# Merge VERSION_FROM to VERSION_TO
( cd "$pkg_dir"
  echo cvs up -dP -j "$tag_from" -j "$tag_to"
       cvs up -dP -j "$tag_from" -j "$tag_to"

  # Cleanup backup files by cvs
  find . -type f -name ".#*" | xargs rm -f
)

# Remove files those are not Added or Modified
echo -n "Remove files those are not Added or Modified ..."
( cd "$pkg_dir"

  find . -type f | grep -v /CVS/ | while read line ; do
    result="` cvs -nq up "$line" 2>/dev/null | grep '^[AM] ' | cut -b 3- `"
    test "x$result" != "x" || rm -f "$line"
    echo -n "."
  done
  echo
)

# Remove CVS directories
echo "Remove CVS directories ..."
find "$pkg_dir" -type d -name "CVS" | xargs rm -Rf

# Remove '.cvsignore' if exists
echo find "$pkg_dir" -type f -name '.cvsignore' -delete
     find "$pkg_dir" -type f -name '.cvsignore' -delete

# Remove emptied directories (twice)
find "$pkg_dir" -type d -empty | xargs rmdir
find "$pkg_dir" -type d -empty | xargs rmdir

# Move / Copy *.ini.php files
if [ 'x' != "x$__copy_dist$__move_dist" ] ; then
( cd "$pkg_dir"

  find . -type f -name "*.ini.php" | while read file; do
    dist_file="` echo "$file" | sed 's/ini\.php$/ini-dist.php/' `"
    mv -f "$file" "$dist_file"
    test "$__copy_dist" && cp -f "$dist_file" "$file"
  done
)
fi

# chmod
chmod_pkg "$pkg_dir"

if [ -z "$__zip" ]
then
  # Tar
  echo tar cf - "$pkg_dir" \| gzip -9 \> "update_$rel_to.tar.gz"
       tar cf - "$pkg_dir"  | gzip -9  > "update_$rel_to.tar.gz"
else
  # Zip
  echo zip -r9 "update_$rel_to.zip" "$pkg_dir"
       zip -r9 "update_$rel_to.zip" "$pkg_dir"
fi

#echo rm -Rf   "$pkg_dir"
#     rm -Rf   "$pkg_dir"

