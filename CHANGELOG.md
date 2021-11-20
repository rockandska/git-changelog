# CHANGELOG

## [0.2.1](https://github.com/rockandska/git-changelog/tree/0.2.1)

### fix

- extra line is missing in some commits (#3) ([8f92f76](https://github.com/rockandska/git-changelog/commit/8f92f76b47885382ba171be5c810ea90a785714d))

## [0.2.0](https://github.com/rockandska/git-changelog/tree/0.2.0)

### feat

- let users interact with conventional commits regex / sections to show ([bd7a5b9](https://github.com/rockandska/git-changelog/commit/bd7a5b9960aabdb8864dce7933e9a3abe159d05f))

### fix

- changelog updated when launched twice with tag ([9637e06](https://github.com/rockandska/git-changelog/commit/9637e06bf9784b82885a386b08bc385321333262))
- make config variables local ([525fddf](https://github.com/rockandska/git-changelog/commit/525fddfb937cc37f3f7891e3867909c910f4a44b))

## [0.1.0](https://github.com/rockandska/git-changelog/tree/0.1.0)

### feat

- add command arguments to print and set tag ([d56b620](https://github.com/rockandska/git-changelog/commit/d56b62082bd4dad99ca3c77bc7bd9363c7f8b31a))
- add capability to show commits body ([706f6cf](https://github.com/rockandska/git-changelog/commit/706f6cfac71a963a0a3087a5b325857649b4c738))
- add type/scope traduction capability ([f9aac69](https://github.com/rockandska/git-changelog/commit/f9aac699fddc0c4d37e7ba5a87ec9eeddae7f01d))
- add capability to show scope section ([d3135ca](https://github.com/rockandska/git-changelog/commit/d3135ca58c515e11f95ecd8b172078522b3ecfd0))
- add user/repo config ([b7c149c](https://github.com/rockandska/git-changelog/commit/b7c149cde8e9744776188de41379385b09945225))
- show breaking changes ([72ee055](https://github.com/rockandska/git-changelog/commit/72ee055634974fb563b4e37c1ef224d6656a76e4))

### fix

- only print update message if something is done ([358a6c7](https://github.com/rockandska/git-changelog/commit/358a6c7165cb60b9f78fe0fe6c45298c26c6c5f6))
- check tags only present in current branch ([fc1fe5b](https://github.com/rockandska/git-changelog/commit/fc1fe5bc0c43455e1382e9a78a24231c3ce36623))
- add entrypoint to prevent to add 'changelog' as argument ([d90c863](https://github.com/rockandska/git-changelog/commit/d90c86371129af15dd415e677e3029ce5fea8059))
- call git log only once ([e8d1d1e](https://github.com/rockandska/git-changelog/commit/e8d1d1e160a023a7de57d1af12781ca3d9b64a08))
- don't include in GIT_COMMITS commits not used ([027fb6b](https://github.com/rockandska/git-changelog/commit/027fb6bf484b71a02e84b729c95e4d7e9da23a45))
- keep existing CHANGELOG intact ([f85f03a](https://github.com/rockandska/git-changelog/commit/f85f03a9ec0e4c996f57f3276f999bde9317d9b9))
- first commit not in commits list ([64d33cc](https://github.com/rockandska/git-changelog/commit/64d33cc2841774f2f657a6661a16586cf86f5161))

## 0.0.3

### fix

- only generate CHANGELOG if at least 1 conventional commit (1f0c8ba)

## 0.0.2

### fix

- improve conventional commit regex (bf2dac7)
- don't fail if nothing is commited (334c1c4)

## 0.0.1

### fix

- First release (8216de6)
