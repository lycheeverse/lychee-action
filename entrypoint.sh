#!/bin/bash -l
set -uxo pipefail

LYCHEE_TMP="/tmp/lychee/out.md"
GITHUB_WORKFLOW_URL="https://github.com/${GITHUB_REPOSITORY}/actions/runs/${GITHUB_RUN_ID}?check_suite_focus=true"

# Create temp dir
mkdir -p "$(dirname $LYCHEE_TMP)"

ARGS="${INPUT_ARGS}"
FORMAT=""
# Backwards compatibility:
# If `format` occurs in args, ignore the value from `INPUT_FORMAT`
[[ "$ARGS" =~ "--format " ]] || FORMAT="--format ${INPUT_FORMAT}"

# Execute lychee
eval lychee ${FORMAT} --output ${LYCHEE_TMP} ${ARGS} 
exit_code=$?

if [ ! -f "${LYCHEE_TMP}" ]; then
    echo "No output. Check pipeline run to see if lychee panicked." > "${LYCHEE_TMP}"
fi

# Overwrite the error code in case no links were found
# and `fail-if-empty` is set to `true` (and it is by default)
if [ "${INPUT_FAILIFEMPTY}" = true ]; then
    # This is a somewhat crude way to check the Markdown output of lychee
    if echo "${LYCHEE_TMP}" | grep -E 'Total\s+\|\s+0'; then
        echo "No links were found. This usually indicates a configuration error." >> "${LYCHEE_TMP}"
        echo "If this was expected, set 'fail-if-empty: true' in the args." >> "${LYCHEE_TMP}"
        exit_code=1
    fi
fi

# If link errors were found, create a report in the designated directory
if [ $exit_code -ne 0 ]; then
    mkdir -p "$(dirname -- "${INPUT_OUTPUT}")"
    cat "${LYCHEE_TMP}" > "${INPUT_OUTPUT}"

    if [ "${INPUT_FORMAT}" == "markdown" ]; then
        echo "[Full Github Actions output](${GITHUB_WORKFLOW_URL})" >> "${INPUT_OUTPUT}"
    fi
fi

# Output to console
cat "${LYCHEE_TMP}"
echo

if [ "${INPUT_FORMAT}" == "markdown" ]; then
  if [ "${INPUT_JOBSUMMARY}" = true ]; then
    cat "${LYCHEE_TMP}" > "${GITHUB_STEP_SUMMARY}"
  fi
fi

# Pass lychee exit code to next step
echo ::set-output name=exit_code::$exit_code

# If `fail` is set to `true`, propagate the real exit value to the workflow
# runner. This will cause the pipeline to fail on exit != 0.
if [ "$INPUT_FAIL" = true ]; then
    exit ${exit_code}
fi
