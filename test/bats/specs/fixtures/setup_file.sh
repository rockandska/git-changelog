setup_file() {
  # shellcheck disable=SC2034
  if [ -z "${BATS_PROJECT_DIR+x}" ];then
    1>&2 echo "Error: BATS_PROJECT_DIR is not set"
    return 1
  fi
  PATH="${BATS_PROJECT_DIR}:${PATH}"
  if ! git config user.name &> /dev/null;then
    git config --global user.name test
    git config --global user.email "test@test.com"
    git config --global init.defaultBranch master
  fi
}
