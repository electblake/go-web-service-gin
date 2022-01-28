# web-service-gin
> written in go

As part of [go.dev: Developing a RESTful API with Go and Gin](https://go.dev/doc/tutorial/web-service-gin)

### Added Scope/Features
- added delete album by id
- integration tests (see Testing below)
- integration tests start server and wait for ready before execution (see [./test.bats](./test.bats) `setup_file` and `teardown_file`)

## Testing
---

### Requirements

**install [golang](https://go.dev)**
```sh
brew install go
```

**install bats ([Bash Testing Framework](https://github.com/bats-core/bats-core))**
```sh
brew install bats-core
bats --version # 1.5.0 (at time of this writing)
```

**install [bats-asserts](https://github.com/bats-core/bats-assert)**
```sh
git submodule init # initialize test/test_helpers for bats
git submodule update # might as well git pull helpers
```

**install [httpie](https://httpie.io)**
```sh
brew install httpie
```

### Run tests

```sh
$ make test

bats ./test.bats --print-output-on-failure

go run server pid: 64625
 - output: /var/folders/cb/12sr16q524vfxw14j0wmcqnr0000gn/T/0.4Mz
 - wait...
> Server is running, test:
 ✓ get albums
  - status: 0
 ✓ get album by id
  - status: 0
 ✓ post albums
  - status: 0
 ✓ delete album by id
  - status: 0
kill 64625

```

### Integration Testing using HTTPie
- httpie as http lib - I like its interface and wanted to make it more use of it
- HTTP requests are made to a running server during the bats execution.
- The server is started with `go run . &` and the process is pushed to background
- integration tests waits until `localhost:8080` appears in server output
- see [./test.bats](./test.bats) `setup_file` and `teardown_file`
