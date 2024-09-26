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

# If `output` occurs in args and `INPUT_OUTPUT` is set, exit with an error 
if [[ "$ARGS" =~ "--output " ]] && [ -n "${INPUT_OUTPUT:-}" ]; then
    echo "Error: 'output' is set in args as well as in the action configuration. Please remove one of them."
    exit 1
fi

# Execute lychee
eval lychee ${FORMAT} --output ${LYCHEE_TMP} ${ARGS} 
exit_code=$?

# Overwrite the exit code in case no links were found
# and `fail-if-empty` is set to `true` (and it is by default)
if [ "${INPUT_FAILIFEMPTY}" = "true" ]; then
    # Explicitly set INPUT_FAIL to true to ensure the script fails
    # if no links are found
    INPUT_FAIL=true
    # This is a somewhat crude way to check the Markdown output of lychee
    if grep -E 'Total\s+\|\s+0' "${LYCHEE_TMP}"; then
        echo "No links were found. This usually indicates a configuration error." >> "${LYCHEE_TMP}"
        echo "If this was expected, set 'fail-if-empty: false' in the args." >> "${LYCHEE_TMP}"
        exit_code=1
    fi
fi

if [ ! -f "${LYCHEE_TMP}" ]; then
    echo "No output. Check pipeline run to see if lychee panicked." > "${LYCHEE_TMP}"
else
    # If we have any output, create a report in the designated directory
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
echo "exit_code=$exit_code" >> $GITHUB_OUTPUT

# If `fail` is set to `true` (and it is by default), propagate the real exit
# value to the workflow runner. This will cause the pipeline to fail on 
# `exit != # 0`.
if [ "$INPUT_FAIL" = true ] ; then
    exit ${exit_code}
fi
