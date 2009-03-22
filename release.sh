#!/bin/sh
# $Id: release.sh,v 1.30 2009/03/22 15:41:14 henoheno Exp $
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
  warn  "    --nopkg     Suppress creating archive (Extract and chmod only)"
  warn  "    --norm      --nopkg, and remove nothing (.cvsignore etc)"
  warn  "    --co        --norm, and use 'checkout' command instead of 'export'"
  warn  "    --utf8      Create UTF-8 converted archive (EXPERIMENTAL)"
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
    [1-9].[0-9].[0-9]_[1-9]_[a-z]*  | [1-9].[0-9].[0-9][0-9]_[1-9]_[a-z]*  ) tag="r$1" ;;
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

# Function verifying arguments ------------------------------

getopt(){ _arg=noarg
  trace 'getopt()' "$@"  # (DEBUG)

  case "$1" in
  ''  )  echo 1 ;;
  -[hH]|--help ) echo _help _exit ;;
  --debug      ) echo _debug 1    ;;
  --nopkg      ) echo _nopkg 1    ;;
  --norm|--noremove ) echo _nopkg _noremove 1 ;;
  --co|--checkout   ) echo _nopkg _noremove _checkout 1 ;;
  -z|--zip     ) echo _zip 1      ;;
  --ut|--utf|--utf8|--utf-8 ) echo _utf8 1  ;;
  --copy-dist  ) echo _copy_dist 1 ;;
  --move-dist  ) echo _move_dist 1 ;;
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

     _*      ) eval "_$ch"=on ;;
      *      ) break 2   ;;
    esac
  done
done

# No argument
if [ $# -eq 0 ] ; then usage ; exit ; fi

# Utility check ---------------------------------------------

if [ "$__utf8" ] ; then

  # nkf
  which nkf || err "nkf version 2.0 or later (UTF-8 enabled) not found"
  nkf_version="` nkf -v 2>&1 | sed -e '/^Network Kanji Filter/!d' -e 's/.* Version \([1-9]\).*/\1/' `"
  if [ "$nkf_version" = '1' -o "$nkf_version" = '0' ] ; then
    err "nkf found but not seems 2.x (UTF-8 enabled) or later"
  fi

  # encls.php
  encls="./encls.php"
  if [ ! -f "$encls" ]
  then err "encls not found"
  else
    php="` which php `"        || err "php-cli not found"
    test -f /usr/local/bin/php || err "/usr/local/bin/php not found (but $php found)"
    encls="`pwd`/$encls"
  fi

  convert(){
    for list in "$@" ; do
      # NOTE: Specify '-E'(From EUC-JP) otherwise skin file will be collapsed
      nkf -Ew "$list" > "$list.$$.tmp" && mv "$list.$$.tmp" "$list" && echo "  $list"
    done
  }
  convert_EUCJP2UTF8(){
    for list in "$@" ; do
      # Very rough conversion!
      #sed 's/EUC-JP/UTF-8/g' "$list" > "$list.$$.tmp" && mv "$list.$$.tmp" "$list"
      sed 's#^//UTF-8:##' "$list" > "$list.$$.tmp" && mv "$list.$$.tmp" "$list"
    done
  }
fi > /dev/null

if [ -z "$__zip" ]
then
  which tar  || err "tar not found"
  which gzip || err "gzip not found"
else
  which zip  || err "zip not found"
fi > /dev/null

# Argument check --------------------------------------------

rel="$1"
tag="` check_versiontag "$rel" `" || exit 1
pkg_dir="${mod}-${rel}"

if [ "$__utf8" ] ; then
  pkg_dir="${pkg_dir}_utf8"
fi

# Export the module -----------------------------------------

test ! -d "$pkg_dir" || err "There's already a directory: $pkg_dir"

if [ -z "$__checkout" ]
then cmd="export"
else cmd="checkout"
fi

echo cvs -z3 -d "$CVSROOT" -q "$cmd" -r "$tag" -d "$pkg_dir" "$mod"
     cvs -z3 -d "$CVSROOT" -q "$cmd" -r "$tag" -d "$pkg_dir" "$mod"

test   -d "$pkg_dir" || err "There isn't a directory: $pkg_dir"

# Remove '.cvsignore' if exists -----------------------------
test -z "$__noremove" && {
  echo find "$pkg_dir" -type f -name '.cvsignore' "| xargs rm -f"
       find "$pkg_dir" -type f -name '.cvsignore' | xargs rm -f
}

# Conversion ------------------------------------------------

if [ "$__utf8" ] ; then
  echo "Converting EUC-JP => UTF-8 ..."
  find "$pkg_dir" -type f \( -name "*.txt" -or -name "*.php" -or -name "*.lng"  -or -name "*.dat" -or -name "*.ref" \) |
  while read line; do
    convert "$line"
  done

  # Replace 'EUC-JP' => 'UTF-8'
  ( cd "$pkg_dir" &&
    convert_EUCJP2UTF8 lib/init.php skin/pukiwiki.skin*.php
  )

  # Filename encoded 'encoded-EUC-JP' to 'encoded-UTF-8'
  echo "Renaming encoded-EUC-JP => encoded-UTF-8 ..."
  ( cd "$pkg_dir" &&
    for dir in wiki wiki.en cache; do
      ( cd "$dir" &&
        ls *.txt *.ref *.rel 2>/dev/null | while read line; do
	  target="`$encls "$line" 2>/dev/null`" || exit 1
	  if [ "x$line" != "x$target" ] ; then
            echo " " mv "$dir/$line" "$dir/$target"
                     mv "$line" "$target" || exit 1
	  fi
        done
      ) || exit 1
    done
  ) || err "stop."
fi

# chmod -----------------------------------------------------

chmod_pkg "$pkg_dir"

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

