# Configuration

## Custom configuration

Configuration could be changed at the user level or at the repo level

Configuration is done by providing file(s) with BASH variables declarations.

### User configuration

If exists, `~/.config/git-changelog/config` will be loaded.

Use this configuration to change git-changelog behavior for all git-changelog generated

### Repo configuration

If a file named `.git-changelog` is present at the root of your repo, this file will be loaded.

Use this configuration to change git-changelog behavior for a specific repo.

## Git variables

Variables available for use in templates variables.

- **`tag`**
    - Type: string
    - current tag if exists else empty
- **`type`**
    - Type: string
    - current commit type ( feat, fix, etc.. )
- **`scope`**
    - Type: string
    - current commit scope
- **`hash`**
    - Type: string
    - current commit hash

## Conventional commits variables

Available variables who could be changed are :

- **`conventional_commit_regex`**
    - Type: String
    - Used to detect conventionnal commits
    - Default! `conventional_commit_regex="^(build|chore|ci|docs|feat|fix|perf|refactor|revert|style|test){1}(\(([[:alnum:]._-]+)\))?(!)?: ([[:print:]]*)"`
- **`conventional_commit_to_show`**
    - Type: Array
    - Used to decide which commits type should be shown in CHANGELOG
    - Default: `conventional_commit_to_show=("BREAKING_CHANGES" "feat" "fix")`

## Templating variables

Available variables who could be changed are :

- **`show_scope`**
    - Type: string
    - Will show commits grouped by scope if set to non empty
    - Default: `show_scope=`
- **`show_body`**
    - Type: string
    - Will show commits body under description if set to non empty
    - Default: `show_body=`
- **`header_tpl`**
    - Type: Array
    - Used to generate HEADER section
    - Default: `header_tpl=('%s\n\n' 'CHANGELOG')`
- **`release_tpl`**
    - Type: Array
    - Used to generate RELEASE section when a tag exists
    - Default: `release_tpl=('%s\n\n' "${tag}")`
- **`unreleased_tpl`**
    - Type: Array
    - Used to generate UNRELEASED section when no tag exists
    - Default: `unreleased_tpl=('%s\n\n' 'Unreleased')`
- **`type_tpl`**
    - Type: Array
    - Used to generate TYPE section who regroup all commits from same type
    - Default: `type_tpl=('%s\n\n' "${type}")`
- **`scope_tpl`**
    - Type: Array
    - Used to generate SCOPE section who regroup all commits from same SCOPE inside the TYPE section
    - Default: `scope_tpl=('%s\n\n' "${scope}")`
- **`commit_tpl`**
    - Type: Array
    - Used to display COMMIT informations
    - Default: `commit_tpl=('- %s (%.7s)\n' "${title}" "${hash}")`
- **`commit_type_traduction`**
    - Type: Associative Array
    - Used to convert type to more friendly names
    - Default: `commit_type_traduction=()`
- **`commit_scope_traduction`**
    - Type: Associative Array
    - Used to convert scope to more friendly names
    - Default: `commit_scope_traduction=()`

## Examples

We assume a git log like the one bellow :

```bash
$ git log --oneline
9c15fbc (HEAD -> master) fix: update config function
c2b76cb feat(deps)!: update core deps
b256e66 feat(deps): update deps
a6ad08c fix(test): add new test
22b8e45 chore: first release
```

### Default

---

```bash
$ git changelog -p
```
```bash
# CHANGELOG

## Unreleased

### BREAKING_CHANGES

- update config function (9c15fbc)
- update core deps (c2b76cb)

### feat

- update deps (b256e66)

### fix

- add new test (a6ad08c)
```

---

### Show scope and body

---

```bash
$ cat > .git-changelog <<EOF
show_body=1
show_scope=1
EOF
```
```bash
$ git changelog -p
# CHANGELOG

## Unreleased

### BREAKING_CHANGES

#### deps

- update core deps (c2b76cb)

#### no scope

- update config function (9c15fbc)
  ```
  previous function had a bug
  
  BREAKING CHANGE: tcp_keep_alive parameter not available anymore
  ```

### feat

#### deps

- update deps (b256e66)

### fix

#### test

- add new test (a6ad08c)
```

---

### Add traductions

---

```bash
$ cat >> .git-changelog <<EOF
commit_type_traduction["fix"]="Fixtures"
commit_type_traduction["feat"]="Features"
commit_scope_traduction["deps"]="Dependencies"
commit_scope_traduction["test"]="Tests"
commit_scope_traduction["no scope"]="Without Scope"
EOF
```
```bash
$ git changelog -p
# CHANGELOG

## Unreleased

### BREAKING_CHANGES

#### Dependencies

- update core deps (c2b76cb)

#### Without Scope

- update config function (9c15fbc)
  ```
  previous function had a bug

  BREAKING CHANGE: tcp_keep_alive parameter not available anymore
  ```

### Features

#### Dependencies

- update deps (b256e66)

### Fixtures

#### Tests

- add new test (a6ad08c)
```

---

### Add repo url / commit url

---

```bash
$ cat >> .git-changelog <<'EOF'
local repo_url='https://github.com/rockandska/git-changelog'
local commit_url="${repo_url}/commit/${hash}"
local release_url="${repo_url}/tree/${tag}"
local unreleased_url="${repo_url}/tree/master"
release_tpl=('[%s](%s)\n\n' "${tag}" "${release_url}")
unreleased_tpl=('[%s](%s)\n\n' 'Unreleased' "${unreleased_url}")
commit_tpl=('- %s ([%.7s](%s))\n' "${title:-}" "${hash}" "${commit_url}")
EOF
```
```bash
$ git changelog -p

# CHANGELOG

## [Unreleased](https://github.com/rockandska/git-changelog/tree/master)

### BREAKING_CHANGES

#### Dependencies

- update core deps ([c2b76cb](https://github.com/rockandska/git-changelog/commit/c2b76cb31f754b48c65517f11c9d6205689e772d))

#### Without Scope

- update config function ([9c15fbc](https://github.com/rockandska/git-changelog/commit/9c15fbce76f978087ebe6a3797973d8efd49d935))
  ```
  previous function had a bug
  
  BREAKING CHANGE: tcp_keep_alive parameter not available anymore
  ```

### Features

#### Dependencies

- update deps ([b256e66](https://github.com/rockandska/git-changelog/commit/b256e663840e777ce1723fc89ead36f69fd7bb0f))

### Fixtures

#### Tests

- add new test ([a6ad08c](https://github.com/rockandska/git-changelog/commit/a6ad08c73189f3fa8db097bd76125f2332a655a8))
```
