#!/bin/sh

COUNT_ALL=`wc -l $1 | cut -f 1 -d " "`
if [ -z $2 ]; then
  MAX_LINES_ONE_FILE=20000
else
  MAX_LINES_ONE_FILE=$2
fi

echo "COUNT_ALL is: ${COUNT_ALL}"
echo "MAX_LINES_ONE_FILE is: ${MAX_LINES_ONE_FILE}"

if [ $COUNT_ALL -gt $MAX_LINES_ONE_FILE ]; then
  let "END_POINT=(${COUNT_ALL}-${MAX_LINES_ONE_FILE})"

  echo "END_POINT is: ${END_POINT}"

  sed -i -e "1,${END_POINT}d" "$1"
fi

