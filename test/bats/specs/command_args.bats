load fixtures/setup_file.sh

setup() {
  cd $BATS_TEST_TMPDIR
}

@test "command args -p should works" {
  git init
  git commit --allow-empty -m"fix: add fix"
  run git-changelog -p
  git_commit=$(git rev-parse --short HEAD)
  diff <(echo "$output") <(cat <<EOF
# CHANGELOG

## Unreleased

### fix

- add fix (${git_commit})
EOF
)
}

@test "command args -p and -n should works" {
  git init
  git commit --allow-empty -m"fix: add fix"
  run git-changelog -p -n 0.0.4
  git_commit=$(git rev-parse --short HEAD)
  diff <(echo "$output") <(cat <<EOF
# CHANGELOG

## 0.0.4

### fix

- add fix (${git_commit})
EOF
)
}
