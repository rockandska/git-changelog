load fixtures/setup_file.sh

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

@test "update changelog with 1 commit (fix) works" {
  cat >> ${BATS_TEST_TMPDIR}/CHANGELOG.md <<EOF
# CHANGELOG

## 0.0.1

### fix

- add fix (0000000)

EOF
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

## 0.0.1

### fix

- add fix (0000000)

EOF
)
}

@test "redo an unreleased CHANGELOG should not change" {
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
  run git-changelog
  diff "${BATS_TEST_TMPDIR}/CHANGELOG.md" <(cat <<EOF
# CHANGELOG

## Unreleased

### fix

- add fix (${git_commit})

EOF
)
}

@test "redo a release CHANGELOG should not change" {
  git init
  git commit --allow-empty -m"fix: add fix"
  run git-changelog -n 0.0.1
  [ "$output" == "${BATS_TEST_TMPDIR}/CHANGELOG.md updated !" ]
  git_commit=$(git rev-parse --short HEAD)
  diff "${BATS_TEST_TMPDIR}/CHANGELOG.md" <(cat <<EOF
# CHANGELOG

## 0.0.1

### fix

- add fix (${git_commit})

EOF
)
  run git-changelog -n 0.0.1
  diff "${BATS_TEST_TMPDIR}/CHANGELOG.md" <(cat <<EOF
# CHANGELOG

## 0.0.1

### fix

- add fix (${git_commit})

EOF
)
}
