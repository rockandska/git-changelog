load fixtures/setup_file.sh

setup() {
  cd $BATS_TEST_TMPDIR
}

@test "fail if not a git repository" {
  run git-changelog
  [ "$output" == "fatal: not a git repository (or any of the parent directories): .git" ]
  [ "$status" -eq 128 ]
}

@test "don't fail if new repository without commits" {
  run git init
  [ "$output" == "Initialized empty Git repository in ${BATS_TEST_TMPDIR}/.git/" ]
  [ "$status" -eq 0 ]
  run git-changelog
  [ "$output" == "No changes made to ${BATS_TEST_TMPDIR}/CHANGELOG.md" ]
  [ "$status" -eq 0 ]
}
