load fixtures/setup_file.sh

setup() {
  cd $BATS_TEST_TMPDIR
}

@test "new changelog with breaking change in title works" {
  git init
  git commit --allow-empty -m"fix!: add fix"
  run git-changelog
  [ "$output" == "${BATS_TEST_TMPDIR}/CHANGELOG.md updated !" ]
  git_commit=$(git rev-parse --short HEAD)
  diff "${BATS_TEST_TMPDIR}/CHANGELOG.md" <(cat <<EOF
# CHANGELOG

## Unreleased

### BREAKING_CHANGES

- add fix (${git_commit})

EOF
)
}

@test "new changelog with breaking change in footer works" {
  git init
  git commit --allow-empty -m "fix: add fix" -m "description" -m "BREAKING CHANGE: break"
  run git-changelog
  #[ "$output" == "${BATS_TEST_TMPDIR}/CHANGELOG.md updated !" ]
  git_commit=$(git rev-parse --short HEAD)
  diff "${BATS_TEST_TMPDIR}/CHANGELOG.md" <(cat <<EOF
# CHANGELOG

## Unreleased

### BREAKING_CHANGES

- add fix (${git_commit})

EOF
)
}

