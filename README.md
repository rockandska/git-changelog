# git-changelog

## Description

A custom git command to generate/update CHANGELOG from conventional commits

## Quick start

### Global system install

Put `git-changelog` in a directory present in `$PATH`

```shell
$ RELEASE= # put a tag here if you want a specific release
$ TARGET="${HOME}/.local/bin/git-changelog"
$ wget -O "${TARGET}" https://raw.githubusercontent.com/rockandska/git-changelog/${RELEASE:=master}/git-changelog
$ chmod +x "${TARGET}"
```

### Display usage

#### From system installation

```shell
$ git changelog -h
```

#### With docker

```shell
$ docker run --rm -ti -v $(pwd):/git rockandska/git-changelog -h
```

### Generate `unreleased` section

#### From system installation

```shell
$ git changelog
```

#### With docker

```shell
$ docker run --rm -ti -v $(pwd):/git rockandska/git-changelog
```

### Generate an `1.0.0` section

#### From system installation

```shell
$ git changelog -n 1.0.0
```

#### With docker

```shell
docker run --rm -ti -v $(pwd):/git rockandska/git-changelog -n 1.0.0
```

## Documentation

Visit: [https://git-changelog-bash.readthedocs.io/](https://git-changelog-bash.readthedocs.io/)
