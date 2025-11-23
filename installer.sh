#!/usr/bin/env bash
# Installs pypi dependencies from a requirements file.

set -ex

COMPOSER_PYTHON_VERSION="${1}"
FAIL_ON_CONFLICT="${2}"

if [ "${COMPOSER_PYTHON_VERSION::1}" == "3" ]; then
  PYTHON=python3
  echo "Installing Python3 Requirements."
else
  PYTHON=python2
  echo "Installing Python2 Requirements."
fi

${PYTHON} -m pip install -r requirements.txt
# FIXME: Why can we ignore conflicts? We should fail if there is a conflict.
# Check for conflicts. Fail if conflicts are not ignored to prevent image generation.
${PYTHON} -m pipdeptree --warn
if [[ -z "${FAIL_ON_CONFLICT}" ]]; then
  # Running plugins manager to fail the on-going image build when accepted
  # conflicts crash it.
  ${PYTHON} -c "from airflow import plugins_manager"
else
  # Use `pip check` instead of `pipdeptree --warn fail` to avoid fail on circular dependencies.
  ${PYTHON} -m pip check
fi
