#!/bin/sh
# $Id: pkwk_chmod.sh,v 1.3 2011/01/16 14:50:06 henoheno Exp $
#  ==========================================================
   Copyright='(C) 2002-2004 minix-up project, All Rights Reserved'
   Homepage='http://cvsknit.sourceforge.net/'
   License='(also revised)BSD Licnese, NO WARRANTY'
#


# chmod o+r *.php */*.php
# chmod o+r lib skin plugin image image/face doc
#    chmod 777 attach backup cache counter diff trackback wiki* 2>/dev/null
#    chmod 666 wiki*/*.txt cache/*.dat cache/*.ref cache/*.rel  2>/dev/null

check_dir()
{
  for dir in "$@"; do
    test -d "$dir" || return 1
  done
  return 0
}

list_dir()
{
  # Needed
  echo 'wiki'
  echo 'diff'
  echo 'backup'

  # Optional
  ls -d 'cache' 'counter' 'attach' wiki.[a-z][a-z] 2>/dev/null | while read dir; do
    echo "$dir"
  done
}

list_files()
{
  for dir in "$@"; do
    case "$dir" in
      attach )
         # Unfortunately attach/attached-files have no suffix
         # that should be .bin or someting
         find "$dir" -type f -name '*.log'
      ;;
      backup ) find "$dir" -type f \( -name '*.txt' -or -name '*.gz'     \) ;;
      cache  ) find "$dir" -type f \( -name '*.dat' -or -name '*.re[fl]' \) ;;
      *      ) find "$dir" -type f -name '*.txt' ;;
    esac
  done
}


# Validate
if ! check_dir ` list_dir ` ; then
  echo 'ERROR: Seems not pukiwiki DATA_HOME'
  exit 1
fi

# Run
list_dir | while read dir; do
  chmod 777 "$dir" && {
    list_files "$dir" | while read file; do
      chmod 666 "$file"
    done
  }
done

