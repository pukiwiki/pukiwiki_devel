#!/bin/sh
# $Id: release_update.sh,v 1.3 2004/09/11 14:29:50 henoheno Exp $
# $CVSKNIT_Id: release.sh,v 1.11 2004/05/28 14:26:24 henoheno Exp $
#  Release automation script for PukiWiki
#  ==========================================================
   Copyright='(C) 2002-2004 minix-up project, All Rights Reserved'
   Homepage='http://cvsknit.sourceforge.net/'
   License='BSD Licnese, NO WARRANTY'
#

# Functions -----------------------------------------------
warn(){  echo "$*" 1>&2 ; }
err() {  warn "Error: $*" ; exit 1 ; }

usage(){
  warn "USAGE: `basename $0` VERSION_FROM VERSION_TO (VERSION = '1.4.3_rc1' like)"
  return 1
}

check_versiontag(){
  case "$1" in
    [1-9].[0-9]               | [1-9].[0-9]                    ) tag="r$1" ;;
    [1-9].[0-9]_rc[1-9]       | [1-9].[0-9]_rc[1-9]            ) tag="r$1" ;;
    [1-9].[0-9].[0-9]         | [1-9].[0-9].[0-9][0-9]         ) tag="r$1" ;;
    [1-9].[0-9].[0-9]_rc[1-9] | [1-9].[0-9].[0-9][0-9]_rc[1-9] ) tag="r$1" ;;
    '' ) usage ; return 1 ;;
     * ) warn "Error: Invalid string: $1" ; usage ; return 1 ;;
  esac
  echo "$tag" | tr '.' '_'
}

# -------------------------------------------
# Argument check

rel_from="$1"
rel_to="$2"

tag_from="` check_versiontag "$rel_from" `" || exit
tag_to="`   check_versiontag "$rel_to"   `" || exit

if [ "x$rel_from" = "x$rel_to" ] ; then
  warn "Error: VERSION_FROM and VERSION_TO is equivalent"
  usage ; exit
fi

# -------------------------------------------
# Default

mod=pukiwiki
CVSROOT=":pserver:anonymous@cvs.sourceforge.jp:/cvsroot/$mod"

pkg_dir="$mod"

# -------------------------------------------

# Checkout the module with VERSION_FROM
test ! -d "$pkg_dir" || err "There's already a directory: $pkg_dir"
echo cvs -z3 -d "$CVSROOT" co -r "$tag_from" -d "$pkg_dir" "$mod"
     cvs -z3 -d "$CVSROOT" co -r "$tag_from" -d "$pkg_dir" "$mod"
test   -d "$pkg_dir" || err "There isn't a directory: $pkg_dir"

# Merge VERSION_FROM to VERSION_TO
( cd "$pkg_dir"
  echo cvs up -j "$tag_from" -j "$tag_to"
       cvs up -j "$tag_from" -j "$tag_to"

  # Cleanup backup files by cvs
  find . -type f -name ".#*" | xargs rm -f
)

# Remove files those are not Added or Modified
( cd "$pkg_dir"

  find . -type f | grep -v /CVS/ | while read line ; do
    result="` cvs -nq up "$line" 2>/dev/null | grep '^[AM] ' | cut -b 3- `"
    test "x$result" != "x" || rm -f "$line"
    echo -n "."
  done
  echo
)

# Remove CVS directories
  find "$pkg_dir" -type d -name "CVS" | xargs rm -Rf

# Remove '.cvsignore' if exists
echo find "$pkg_dir" -type f -name '.cvsignore' -delete
     find "$pkg_dir" -type f -name '.cvsignore' -delete

# Remove emptied directories
find "$pkg_dir" -type d -empty | xargs rmdir
find "$pkg_dir" -type d -empty | xargs rmdir

# chmod
( cd "$pkg_dir"

  # ALL: Read only
  find . -type d | while read line; do
      chmod 755 "$line"
    done
  find . -type f | while read line; do
      chmod 644 "$line"
    done

  # Add write permission for PukiWiki
  chmod 777 attach backup cache counter diff trackback wiki* 2>/dev/null
  chmod 666 wiki*/*.txt cache/*.dat 2>/dev/null

)

# Tar
echo tar cf - "$pkg_dir" \| gzip -9 \> "update_$rel_to.tar.gz"
     tar cf - "$pkg_dir"  | gzip -9  > "update_$rel_to.tar.gz"

# Zip
echo zip -r9 "update_$rel_to.zip" "$pkg_dir"
     zip -r9 "update_$rel_to.zip" "$pkg_dir"

#echo rm -Rf   "$pkg_dir"
#     rm -Rf   "$pkg_dir"

