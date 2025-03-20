#!/bin/bash -l
set -uo pipefail

# We use ‘set +e’ to prevent the script from exiting immediately if lychee fails.
# This ensures that:
# 1. Lychee exit code can be captured and passed to subsequent steps via `$GITHUB_OUTPUT`.
# 2. This step’s outcome (success/failure) can be controlled according to inputs
#    by manually calling the ‘exit’ command.
set +e

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

# If `--mode` occurs in args and `INPUT_CHECKBOX` is set, exit with an error 
# Use `--mode` instead of `--mode task` to ensure that the checkbox is not getting overwritten
if [[ "$ARGS" =~ "--mode" ]] && [ -n "${INPUT_CHECKBOX:-}" ]; then
  echo "Error: '--mode' is set in args but 'checkbox' is set in the action configuration. Please remove one of them to avoid conflicts."
  exit 1
fi

CHECKBOX=""
if [ "${INPUT_CHECKBOX}" = true ]; then
  # Check if the version is higher than 0.18.1
  if [ "$(lychee --version | head -n1 | cut -d" " -f4)" -lt 0.18.1 ]; then
    echo "WARNING: 'checkbox' is not supported in lychee versions lower than 0.18.1. Continuing without 'checkbox'."
  else
    CHECKBOX="--mode task"
  fi
fi

# Execute lychee
eval lychee ${CHECKBOX} ${FORMAT} --output ${LYCHEE_TMP} ${ARGS} 
LYCHEE_EXIT_CODE=$?

# If no links were found and `failIfEmpty` is set to `true` (and it is by default),
# fail with an error later, but leave lychee exit code untouched.
should_fail_because_empty=false
if [ "${INPUT_FAILIFEMPTY}" = "true" ]; then
    # This is a somewhat crude way to check the Markdown output of lychee
    if grep -E 'Total\s+\|\s+0' "${LYCHEE_TMP}"; then
        echo "No links were found. This usually indicates a configuration error." >> "${LYCHEE_TMP}"
        echo "If this was expected, set 'failIfEmpty: false' in the args." >> "${LYCHEE_TMP}"
        should_fail_because_empty=true
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

# Pass lychee exit code to subsequent steps
echo "exit_code=$LYCHEE_EXIT_CODE" >> "$GITHUB_OUTPUT"

# Determine the outcome of this step
# Exiting with a nonzero value will fail the pipeline, but the specific value
# does not matter. (GitHub does not share it with subsequent steps for composite actions.)
if [ "$should_fail_because_empty" = true ] ; then
  # If we decided previously to fail because no links were found, fail
  exit 1
elif [ "$INPUT_FAIL" = true ] ; then
  # If `fail` is set to `true` (and it is by default), propagate lychee exit code
  exit ${LYCHEE_EXIT_CODE}
fi
