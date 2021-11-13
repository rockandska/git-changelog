load fixtures/setup_file.sh

setup() {
  cd $BATS_TEST_TMPDIR
}

@test "type traduction should works" {
  echo 'show_scope=1'>  ${BATS_TEST_TMPDIR}/.git-changelog
  echo 'commit_type_traduction["fix"]="Fixtures"'>>  ${BATS_TEST_TMPDIR}/.git-changelog
  git init
  git commit --allow-empty -m"fix(config): add fix"
  git_commit+=($(git rev-parse --short HEAD))
  git commit --allow-empty -m"feat(test): add feat"
  git_commit+=($(git rev-parse --short HEAD))
  git commit --allow-empty -m"feat: add feat"
  git_commit+=($(git rev-parse --short HEAD))
  run git-changelog
  1>&2 echo "$output"
  [ "$output" == "${BATS_TEST_TMPDIR}/CHANGELOG.md updated !" ]
  diff "${BATS_TEST_TMPDIR}/CHANGELOG.md" <(cat <<EOF
# CHANGELOG

## Unreleased

### feat

#### no scope

- add feat (${git_commit[2]})

#### test

- add feat (${git_commit[1]})

### Fixtures

#### config

- add fix (${git_commit[0]})

EOF
)
}

@test "scope traduction should works" {
  echo 'show_scope=1'>  ${BATS_TEST_TMPDIR}/.git-changelog
  echo 'commit_scope_traduction["config"]="Configuration"'>>  ${BATS_TEST_TMPDIR}/.git-changelog
  git init
  git commit --allow-empty -m"fix(config): add fix"
  git_commit+=($(git rev-parse --short HEAD))
  git commit --allow-empty -m"feat(test): add feat"
  git_commit+=($(git rev-parse --short HEAD))
  git commit --allow-empty -m"feat: add feat"
  git_commit+=($(git rev-parse --short HEAD))
  run git-changelog
  1>&2 echo "$output"
  [ "$output" == "${BATS_TEST_TMPDIR}/CHANGELOG.md updated !" ]
  diff "${BATS_TEST_TMPDIR}/CHANGELOG.md" <(cat <<EOF
# CHANGELOG

## Unreleased

### feat

#### no scope

- add feat (${git_commit[2]})

#### test

- add feat (${git_commit[1]})

### fix

#### Configuration

- add fix (${git_commit[0]})

EOF
)
}
