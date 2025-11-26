#!/bin/sh
# SPDX-FileCopyrightText: None
# SPDX-License-Identifier: CC0-1.0

# Parameters:
# $1 - bsd or gnu version of script
# $2 - command to run
# $3 - exit status output file

if [ "$1" = "bsd" ]; then
  script -q /dev/null sh -c "$2"
  echo $? > "$3"
elif [ "$1" = "gnu" ]; then
  script -q /dev/null -c "$2"
  echo $? > "$3"
else
  echo 1 > "$3"
fi
