#!/bin/bash -l
set -uo pipefail

LYCHEE_OUTPUT_DIR=${LYCHEE_OUTPUT_DIR:="lychee"}
LYCHEE_OUTPUT_FILENAME=${LYCHEE_OUTPUT_FILENAME:="out.md"}

# Create temp dir
mkdir -p /tmp/lychee

# Execute lychee
lychee $* >/tmp/lychee/out 2>&1
exit_code=$?

# If link errors were found, create a report in the designated directory
if [ $exit_code -eq 1 ]; then
    mkdir -p $LYCHEE_OUTPUT_DIR
    echo -e '### lychee link checker\nErrors were reported while checking the availability of links.\n```' \
        >$LYCHEE_OUTPUT_DIR/$LYCHEE_OUTPUT_FILENAME
    cat /tmp/lychee/out >>$LYCHEE_OUTPUT_DIR/$LYCHEE_OUTPUT_FILENAME
    echo '```' >>$LYCHEE_OUTPUT_DIR/$LYCHEE_OUTPUT_FILENAME
    echo "Link checker output file: $LYCHEE_OUTPUT_DIR/$LYCHEE_OUTPUT_FILENAME"
fi

# Output to console
cat /tmp/lychee/out

# Pass lychee exit code to next step
echo ::set-output name=exit_code::$exit_code

