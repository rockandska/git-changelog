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
  fi
}

setup() {
  cd $BATS_TEST_TMPDIR
}

@test "new changelog with 1 commit (fix) works" {
  git init
  git commit --allow-empty -m"fix: add fix"
  run git-changelog
  [ "$output" == "${BATS_TEST_TMPDIR}/CHANGELOG.md updated !" ]
  git_commit=$(git rev-parse --short HEAD)
  diff "${BATS_TEST_TMPDIR}/CHANGELOG.md" <(cat <<EOF
# CHANGELOG

## Unreleased

### fix

- add fix (${git_commit})

EOF
)
}

@test "new changelog with 1 commit (feat) works" {
  git init
  git commit --allow-empty -m"feat: add feat"
  run git-changelog
  [ "$output" == "${BATS_TEST_TMPDIR}/CHANGELOG.md updated !" ]
  git_commit=$(git rev-parse --short HEAD)
  diff "${BATS_TEST_TMPDIR}/CHANGELOG.md" <(cat <<EOF
# CHANGELOG

## Unreleased

### feat

- add feat (${git_commit})

EOF
)
}

@test "new changelog with 2 commits (fix/feat) works" {
  git init
  git commit --allow-empty -m"fix: add fix"
  git_commit_fix=$(git rev-parse --short HEAD)
  git commit --allow-empty -m"feat: add feat"
  git_commit_feat=$(git rev-parse --short HEAD)
  run git-changelog
  [ "$output" == "${BATS_TEST_TMPDIR}/CHANGELOG.md updated !" ]
  diff "${BATS_TEST_TMPDIR}/CHANGELOG.md" <(cat <<EOF
# CHANGELOG

## Unreleased

### feat

- add feat (${git_commit_feat})

### fix

- add fix (${git_commit_fix})

EOF
)
}

@test "new changelog with 3 commits (fix/feat/chore) works" {
  git init
  git commit --allow-empty -m"fix: add fix"
  git_commit_fix=$(git rev-parse --short HEAD)
  git commit --allow-empty -m"feat: add feat"
  git_commit_feat=$(git rev-parse --short HEAD)
  git commit --allow-empty -m"chore: add chore"
  run git-changelog
  [ "$output" == "${BATS_TEST_TMPDIR}/CHANGELOG.md updated !" ]
  diff "${BATS_TEST_TMPDIR}/CHANGELOG.md" <(cat <<EOF
# CHANGELOG

## Unreleased

### feat

- add feat (${git_commit_feat})

### fix

- add fix (${git_commit_fix})

EOF
)
}
