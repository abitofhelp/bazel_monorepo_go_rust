# bazel_monorepo_go_rust

This repository contains a monorepo, polyglot project consisting of a library for Go and Rust.  
These libraries can be built using the appropriate native tool -- go build or Cargo -- and Bazel.
The source of truth for dependencies are the go.mod/vendors and Cargo files.
The Makefile contains many queries and commands for using the native tools for Go and Rust within Bazel as well as Bazel commands.

## Valid Bazel Targets
  * //pkg/golang:srcs
  * //pkg/golang/src/grpc_client_lib:grpc_client_lib
  * //pkg/golang/src/grpc_client_lib:grpc_client_lib_test
  * //pkg/rust/src:srcs
  * //pkg/rust/src/grpc_client_lib:grpc_client_lib
  * //pkg/rust/src/grpc_client_lib:grpc_client_lib_test


