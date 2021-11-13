load fixtures/setup_file.sh

setup() {
  cd $BATS_TEST_TMPDIR
}

@test "show body should works" {
  echo 'show_body=1'>>  ${BATS_TEST_TMPDIR}/.git-changelog
  git init
  git commit --allow-empty -m"fix(config): add fix" -m"Line 1" -m "Line 2"
  git_commit+=($(git rev-parse --short HEAD))
  git commit --allow-empty -m"feat(test): add feat"
  git_commit+=($(git rev-parse --short HEAD))
  git commit --allow-empty -m"feat: add feat" -m"Line 1" -m "Line 2"
  git_commit+=($(git rev-parse --short HEAD))
  run git-changelog
  [ "$output" == "${BATS_TEST_TMPDIR}/CHANGELOG.md updated !" ]
  md_output+=("# CHANGELOG")
  md_output+=("")
  md_output+=("## Unreleased")
  md_output+=("")
  md_output+=("### feat")
  md_output+=("")
  md_output+=("- add feat (${git_commit[2]})")
  md_output+=('  ```')
  md_output+=("  Line 1")
  md_output+=("  ")
  md_output+=("  Line 2")
  md_output+=('  ```')
  md_output+=("- add feat (${git_commit[1]})")
  md_output+=("")
  md_output+=("### fix")
  md_output+=("")
  md_output+=("- add fix (${git_commit[0]})")
  md_output+=('  ```')
  md_output+=("  Line 1")
  md_output+=("  ")
  md_output+=("  Line 2")
  md_output+=('  ```')
  md_output+=("")
  diff "${BATS_TEST_TMPDIR}/CHANGELOG.md" <(printf '%s\n' "${md_output[@]}")
}
