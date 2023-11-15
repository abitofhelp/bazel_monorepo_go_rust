# bazel_monorepo_go_rust

This repository contains a monorepo, polyglot project consisting of a library for Go and Rust.  
These libraries can be built using the appropriate native tool -- go build or Cargo -- and Bazel.
The source of truth for dependencies are the go.mod/vendors and Cargo files.
The Makefile contains many queries and commands for using the native tools for Go and Rust within Bazel as well as Bazel commands.

## Valid Bazel Labels
  * //pkg/golang:srcs
  * //pkg/golang/src/grpc_client_lib:grpc_client_lib
  * //pkg/golang/src/grpc_client_lib:grpc_client_lib_test
  * //pkg/rust/src:srcs
  * //pkg/rust/src/grpc_client_lib:grpc_client_lib
  * //pkg/rust/src/grpc_client_lib:grpc_client_lib_test

## To Change Go's and Rust's Versions
  * Execute the set_golang_version command in the Makefile.
  * Execute the set_rust_version command in the Makefile.

## To Add A New Go Project
  * Create a directory in /pkg/golang/src for the new Go project.
  * Clone the files from grpc_client_lib to the new project's directory.
  * Amend the files for the new project's needs.
  * Add the relative path to the new project to the use() in go.work.
    * i.e. /pkg/golang/src/mynewproject
  * You may want to clone the build_grpc_golang_client_lib command in the Makefile for directly building the new project.
  * Verify that you can build the Go projects by executing the go_build_all (go build used) command in the Makefile.
  * Verify that you can build the Go projects by executing the build_all (bazel used) command in the Makefile.

## To Add A New Rust Project
* Create a directory in /pkg/rust/src for the new Rust project.
* Clone the files from grpc_client_lib to the new project's directory.
* Amend the files for the new project's needs.
* Add the bazel target to the new project to the crates_repository.manifests block in the WORKSPACE file.
`    crates_repository(
      name = "crate_index",
      cargo_lockfile = "//:Cargo.lock",
      lockfile = "//:cargo-bazel-lock.json",
      manifests = [
        "//:Cargo.toml",
        "//:pkg/rust/src/grpc_client_lib/Cargo.toml",
        "//:pkg/rust/src/mynewproject/Cargo.toml",
      ],
    )`
  * You may want to clone the build_grpc_rust_client_lib command in the Makefile for directly building the new project.
  * Add the relative path to the new project to the workspace.members block in Cargo.toml file.
`        [workspace]
          resolver = "2"
          members = [
            "pkg/rust/src/grpc_client_lib",
            "pkg/rust/src/mynewproject",
          ]`
* Verify that you can build the Rust projects by executing the rust_build_all (Cargo used) command in the Makefile.
* Verify that you can build the Rust projects by executing the build_all (bazel used) command in the Makefile.