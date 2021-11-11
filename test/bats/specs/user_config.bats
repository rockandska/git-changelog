load fixtures/setup_file.sh

setup() {
  cd $BATS_TEST_TMPDIR
}

@test "user config should works" {
  mkdir -p "${HOME}/.config/git-changelog"
  cat > "${HOME}/.config/git-changelog/config" <<'EOF'
  commit_tpl=('- X %s (%.7s)\n' "${title:-}" "${hash:-}")
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

- X add fix (${git_commit})

EOF
)
}

@test "repo config should works" {
  cat > "${BATS_TEST_TMPDIR}/.git-changelog" <<'EOF'
  commit_tpl=('- X %s (%.7s)\n' "${title:-}" "${hash:-}")
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

- X add fix (${git_commit})

EOF
)
}

@test "repo config should take over user config" {
  mkdir -p "${HOME}/.config/git-changelog"
  cat > "${HOME}/.config/git-changelog/config" <<'EOF'
  commit_tpl=('- X %s (%.7s)\n' "${title:-}" "${hash:-}")
EOF
  cat > "${BATS_TEST_TMPDIR}/.git-changelog" <<'EOF'
  commit_tpl=('- Y %s (%.7s)\n' "${title:-}" "${hash:-}")
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

- Y add fix (${git_commit})

EOF
)
}
