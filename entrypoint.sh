#!/bin/bash -l
set -uo pipefail

# Enable optional debug output
if [ "${INPUT_DEBUG}" = true ]; then
  echo "Debug output enabled"
  set -x
fi

LYCHEE_TMP="$(mktemp)"
GITHUB_WORKFLOW_URL="https://github.com/${GITHUB_REPOSITORY}/actions/runs/${GITHUB_RUN_ID}?check_suite_focus=true"

# If custom GitHub token is set, export it as environment variable
if [ -n "${INPUT_TOKEN:-}" ]; then
    export GITHUB_TOKEN="${INPUT_TOKEN}"
fi

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
echo "lychee_exit_code=$exit_code" >> $GITHUB_ENV

# If `fail` is set to `true`, propagate the real exit value to the workflow
# runner. This will cause the pipeline to fail on exit != 0.
if [ "$INPUT_FAIL" = true ] ; then
    exit ${exit_code}
fi
