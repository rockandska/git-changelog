# git-changelog

## Description

A custom git command to generate/update CHANGELOG from conventional commits

## Warning

Some breaking changes could occur until a stable release

## Global system install

Put `git-changelog` in a directory present in `$PATH`

To generate an `unreleased` section in CHANGELOG.md based on commits from the current repository :

```
git changelog
```

To generate an `1.0.0` section in CHANGELOG.md based on commits from the current repository :

```
CHANGELOG_TAG=1.0.0 git changelog
```

## Docker

To generate an `unreleased` section in CHANGELOG.md based on commits from the current repository :

```
docker run --rm -ti -v $(pwd):/git rockandska/git-changelog changelog
```

To generate an `1.0.0` section in CHANGELOG.md based on commits from the current repository :

```
docker run --rm -ti -v $(pwd):/git -e CHANGELOG_TAG=1.0.0 rockandska/git-changelog changelog
```

## Configuration

Config variables should be BASH array representig a printf expression.

Example:

```bash
commit_tpl=('- %s (%.7s)\n' "${title:-}" "${hash:-}")
```

would be convert to :

```bash
printf -- '- %s (%.7s)\n' "${title:-}" "${hash:-}"
```

### Variables

In configuration, some variables are availables for use

- tag : current tag if exists
- type: current commit type ( feat, fix, etc.. )
- hash: current commit hash

Available variables who could be changed are :

- header_tpl: used to generate a HEADER section
- release_tpl: used to generate release section when a tag exists
- unreleased_tpl: used to generate unreleased section when no tag exists
- type_tpl: used to generate a section who regroup all commits from same type
- commit_tpl: used to display commits informations related to the current type

### Default configuration

```bash
header_tpl=('%s\n\n' 'CHANGELOG')
release_tpl=('%s\n\n' "${tag:-}")
unreleased_tpl=('%s\n\n' 'Unreleased')
type_tpl=('%s\n\n' "${type:-}")
commit_tpl=('- %s (%.7s)\n' "${title:-}" "${hash:-}")
```

### Global user configuration

If exists, `${XDG_CONFIG_HOME:-$HOME/.config}/git-changelog/config` will be
loaded.

Use this configuration to change git-changelog behavior for all git-changelog generated

### Repo configuration

If exists, `${GIT_TOP_LEVEL}/.git-changelog` will be loaded.

Use this configuration to change git-changelog behavior for a specific repo.

## TODO

- write documentation
- add Scope section
- add possibility to convert type to a more friendly name (ex: feat -> Features)
- allow to only print generated CHANGELOG
- allow to go in the past
