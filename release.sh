#!/bin/sh
# $Id: release.sh,v 1.3 2004/09/01 12:22:20 henoheno Exp $
# $CVSKNIT_Id: release.sh,v 1.11 2004/05/28 14:26:24 henoheno Exp $
# Release automation script
#  ==========================================================
   Copyright='(C) 2002-2004 minix-up project, All Rights Reserved'
   Homepage='http://cvsknit.sourceforge.net/'
   License='BSD Licnese, NO WARRANTY'
#

# Functions -----------------------------------------------
warn(){  echo "$*" 1>&2 ; }
err() {  warn "Error: $*" ; exit 1 ; }

usage(){
  warn "USAGE: `basename $0` VERSION_TAG (1.4.3_rc1 like)"
  return 1
}

# -------------------------------------------
# Argument check

rel="$1"
case "$rel" in
  [1-9].[0-9]               | [1-9].[0-9]                    ) tag="r$rel" ;;
  [1-9].[0-9]_rc[1-9]       | [1-9].[0-9]_rc[1-9]            ) tag="r$rel" ;;
  [1-9].[0-9].[0-9]         | [1-9].[0-9].[0-9][0-9]         ) tag="r$rel" ;;
  [1-9].[0-9].[0-9]_rc[1-9] | [1-9].[0-9].[0-9][0-9]_rc[1-9] ) tag="r$rel" ;;
  * ) usage ; exit ;;
esac
tag="` echo "$tag" | tr '.' '_' `"

# -------------------------------------------
# Default

mod=pukiwiki
CVSROOT=":pserver:anonymous@cvs.sourceforge.jp:/cvsroot/$mod"

pkg_dir="${mod}-${rel}"

# -------------------------------------------

# Checkout the module
test ! -d "$pkg_dir" || err "There's already a directory: $mod"
echo cvs -z3 -d "$CVSROOT" export -r "$tag" -d "$pkg_dir" "$mod"
     cvs -z3 -d "$CVSROOT" export -r "$tag" -d "$pkg_dir" "$mod"
test   -d "$pkg_dir" || err "There is'nt a directory: $pkg_dir"


# Remove '.cvsignore' if exists
echo find "$pkg_dir" -type f -name '.cvsignore' -delete
     find "$pkg_dir" -type f -name '.cvsignore' -delete

# chmod
( cd "$pkg_dir"

  # ALL: Read only
  find . -type f | while read line; do
      chmod 644 "$line"
    done

  # Add write permission for PukiWiki
  chmod 777 attach backup cache counter diff trackback wiki*
  chmod 666 wiki*/*.txt cache/*.dat

)

# Tar
echo tar cf - "$pkg_dir" \| gzip -9 \> "$pkg_dir.tar.gz"
     tar cf - "$pkg_dir"  | gzip -9  > "$pkg_dir.tar.gz"

#echo rm -Rf   "$pkg_dir"
#     rm -Rf   "$pkg_dir"

