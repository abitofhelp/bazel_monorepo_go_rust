# Makefile

PROJECT_NAME=bazel_monorepo_go_rust
PROJECT_DIR=$(GOPATH)/src/github.com/abitofhelp/$(PROJECT_NAME)

BZLCMD=bazel
BAZEL_BUILD_OPTS:=--verbose_failures --sandbox_debug
CARGOCMD=$(BZLCMD) run //:cargo # See genrule named "make_cargo" in the root's BUILD.bazel file.
GOCMD=$(BZLCMD) run @io_bazel_rules_go//go
GOLANG_CLIENT_DIR=$(PROJECT_DIR)/pkg/golang/src/grpc_client_lib
GOLANG_CLIENT_LIB_WORKSPACE=//pkg/golang/src/grpc_client_lib
GOLANG_CLIENT_LIB_TARGET=$(GOLANG_CLIENT_LIB_WORKSPACE):grpc_client_lib
PROTO_DIR=$(PROJECT_DIR)/proto
RUST_CLIENT_DIR=$(PROJECT_DIR)/pkg/rust/src/grpc_client_lib
RUST_CLIENT_LIB_WORKSPACE=//pkg/rust/src/grpc_client_lib
RUST_CLIENT_LIB_TARGET=$(RUST_CLIENT_LIB_WORKSPACE):grpc_client_lib

.PHONY:build_all build_client build_proto build_server clean gazelle_update_repos generate_repos go_mod_tidy list run_client run_server test update_repos

build_all: build_grpc_client_libs

build_grpc_golang_client_lib:
	$(BZLCMD) build $(BAZEL_BUILD_OPTS) $(GOLANG_CLIENT_LIB_TARGET)

build_grpc_rust_client_lib:
	$(BZLCMD) build $(BAZEL_BUILD_OPTS) $(RUST_CLIENT_LIB_TARGET)

build_grpc_client_libs: build_grpc_golang_client_lib build_grpc_rust_client_lib

cargo_build_all:
	pushd $(RUST_CLIENT_DIR) && \
	$(CARGOCMD) -- build && \
	popd;

cargo_clean:
	$(CARGOCMD) -- clean

cargo_crate_list:
	$(CARGOCMD) -- package --list

cargo_crate_pub:
	$(CARGOCMD) -- publish -publish $(PROJECT_NAME)

cargo_crate_pub_dryrun:
	$(CARGOCMD) -- publish --dry-run

cargo_targets:
	$(BZLCMD) query "@rules_rust//cargo:*"

clean:
	$(BZLCMD) clean --expunge --async

expand_golang_build:
	$(BZLCMD) query $(GOLANG_CLIENT_LIB_WORKSPACE) --output=build

expand_rust_build:
	$(BZLCMD) query $(RUST_CLIENT_LIB_WORKSPACE) --output=build

gazelle_update_repos:
	# Import repositories from go.mod and update Bazel's macro and rules.
	$(BZLCMD) run $(BAZEL_BUILD_OPTS) //:gazelle -- update-repos -from_file=$(GOLANG_CLIENT_DIR)/go.mod -to_macro=$(PROJECT_DIR)/go_deps.bzl%go_dependencies

generate_repos:
#	 This will generate new BUILD.bazel files for your project. You can run the same command in the future to update existing BUILD.bazel files to include new source files or options.
	$(BZLCMD) run $(BAZEL_BUILD_OPTS) //:gazelle

go_build_all:
	## N.B. Each go.mod file defines a workspace in which the go build, go test, go list, and go get commands are available.  These commands apply to packages only within that workspace.
	## This is why you cannot use go build ./... with a multimodule workspace.
	# Assumes GO111MODULE=on
	pushd $(GOLANG_CLIENT_DIR) && \
	$(GOCMD) -- build ./... && \
	popd;

go_build_grpc_client_lib:
	## N.B. Each go.mod file defines a workspace in which the go build, go test, go list, and go get commands are available.  These commands apply to packages only within that workspace
	# Assumes GO111MODULE=on
	$(GOCMD) -- build $(GOLANG_CLIENT_DIR)

go_mod_tidy:
	## N.B. Each go.mod file defines a workspace in which the go build, go test, go list, and go get commands are available.  These commands apply to packages only within that workspace.
	# Assumes GO111MODULE=on
	pushd $(GOLANG_CLIENT_DIR) && \
	$(GOCMD) -- mod tidy && \
	popd;

go_mod_vendor:
	rm -rf vendor
	## N.B. Each go.mod file defines a workspace in which the go build, go test, go list, and go get commands are available.  These commands apply to packages only within that workspace.
	# Assumes GO111MODULE=on
	pushd $(GOLANG_CLIENT_DIR) && \
	$(GOCMD) -- mod vendor -v && \
	popd;

go_mod_verify:
	## N.B. Each go.mod file defines a workspace in which the go build, go test, go list, and go get commands are available.  These commands apply to packages only within that workspace.
	# Assumes GO111MODULE=on
	pushd $(GOLANG_CLIENT_DIR) && \
	$(GOCMD) -- mod verify && \
	popd;

go_targets:
	$(BZLCMD) query "@io_bazel_rules_go//go:*"

go_unit_test:
	$(BZLCMD) test --test_output=all --test_verbose_timeout_warnings "$(GOLANG_CLIENT_LIB_TARGET)_test"

list:
	$(BZLCMD) query //...

list_crate_index:
	 $(BZLCMD) query @crate_index//...

rust_unit_test:
	$(BZLCMD) test --test_output=all --test_verbose_timeout_warnings "$(RUST_CLIENT_LIB_TARGET)_test"

set_golang_version:
	sed -E -i '.org' 's/go 1.21.3/go 1.21.4/g' "$(PROJECT_DIR)/go.work" && rm "$(PROJECT_DIR)/go.work.org" && \
	sed -E -i '.org' 's/go 1.21.3/go 1.21.4/g' "$(PROJECT_DIR)/go.mod" && rm "$(PROJECT_DIR)/go.mod.org" && \
	sed -E -i '.org' 's/GO_VERSION = "1.21.3"/GO_VERSION = "1.21.4"/g' "$(PROJECT_DIR)/WORKSPACE" && rm "$(PROJECT_DIR)/WORKSPACE.org" ;

set_rust_version:
	sed -E -i '.org' 's/rust-version = "1.73.0"/rust-version = "1.73.1"/g' "$(PROJECT_DIR)/Cargo.toml" && rm "$(PROJECT_DIR)/Cargo.toml.org" && \
	sed -E -i '.org' 's/"1.73.0"/"1.73.1"/g' "$(PROJECT_DIR)/WORKSPACE" && \
	sed -E -i '.org' 's/"nightly\/2023-11-12"/"nightly\/2023-11-13"/g' "$(PROJECT_DIR)/WORKSPACE" && rm "$(PROJECT_DIR)/WORKSPACE.org" ;

sync_from_cargo:
	rm -f cargo-bazel-lock.json
	touch cargo-bazel-lock.json
	@CARGO_BAZEL_REPIN=true $(BZLCMD) sync --only=crate_index

sync_from_gomod: go_mod_verify go_mod_tidy gazelle_update_repos go_mod_vendor

unit_test_all: go_unit_test rust_unit_test

#tidy:
#	@rm -rf vendor
#	go mod tidy
#	go mod vendor -v
#
#zap:
#	@rm go.sum
#	@rm -rf vendor
#	go clean -modcache
#	go mod download
#	go mod tidy
#	go mod vendor -v