COMMITLINT_CONFIG_PATH="$(dirname "${BASH_SOURCE[0]}")/.commitlintrc.yaml"

commitlint --config "${COMMITLINT_CONFIG_PATH}" < "$1"
