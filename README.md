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

## TODO

- write documentation
- load user configuration
- add BREAKING CHANGES
- add Scope section
- add possibility to convert type to a more friendly name (ex: feat -> Features)
- add tests
- allow to only print generated CHANGELOG
- allow to go in the past
