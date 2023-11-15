## WORKSPACE

workspace(name = "bazel_monorepo_go_rust")

## VERSIONS
BAZEL_GAZELLE_VERSION = "0.34.0"

GO_VERSION = "1.21.3"

RULES_GO_VERSION = "0.42.0"

RUST_VERSIONS = [
    "1.73.0",
    "nightly/2023-11-12",
]

RULES_RUST_VERSION = "0.30.0"

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

## RULES_GO AND GAZELLE ###################################################################################
## RULES_GO
http_archive(
    name = "io_bazel_rules_go",
    sha256 = "91585017debb61982f7054c9688857a2ad1fd823fc3f9cb05048b0025c47d023",
    urls = [
        "https://mirror.bazel.build/github.com/bazelbuild/rules_go/releases/download/{version}/rules_go-v{version}.zip".format(version = RULES_GO_VERSION),
        "https://github.com/bazelbuild/rules_go/releases/download/{version}/rules_go-v{version}.zip".format(version = RULES_GO_VERSION),
    ],
)

load("@io_bazel_rules_go//go:deps.bzl", "go_register_toolchains", "go_rules_dependencies")

go_rules_dependencies()

go_register_toolchains(version = "{version}".format(version = GO_VERSION))

## GAZELLE

http_archive(
    name = "bazel_gazelle",
    sha256 = "b7387f72efb59f876e4daae42f1d3912d0d45563eac7cb23d1de0b094ab588cf",
    urls = [
        "https://mirror.bazel.build/github.com/bazelbuild/bazel-gazelle/releases/download/{version}/bazel-gazelle-v{version}.tar.gz".format(version = BAZEL_GAZELLE_VERSION),
        "https://github.com/bazelbuild/bazel-gazelle/releases/download/{version}/bazel-gazelle-v{version}.tar.gz".format(version = BAZEL_GAZELLE_VERSION),
    ],
)

load("@bazel_gazelle//:deps.bzl", "gazelle_dependencies")

gazelle_dependencies()

load("//pkg/golang/src/grpc_client_lib:go_deps.bzl", "go_dependencies")

# gazelle:repository_macro pkg/golang/src/grpc_client_lib/go_deps.bzl%go_dependencies
go_dependencies()
########################################################################################################################

## RULES_RUST AND CRATE_UNIVERSE #######################################################################################
http_archive(
    name = "rules_rust",
    sha256 = "6357de5982dd32526e02278221bb8d6aa45717ba9bbacf43686b130aa2c72e1e",
    urls = ["https://github.com/bazelbuild/rules_rust/releases/download/{version}/rules_rust-v{version}.tar.gz".format(version = RULES_RUST_VERSION)],
)

load("@rules_rust//rust:repositories.bzl", "rules_rust_dependencies", "rust_register_toolchains")

rules_rust_dependencies()

rust_register_toolchains(
    edition = "2021",
    versions = [
        "1.73.0",
        "nightly/2023-11-12",
    ],
)

## CRATE_UNIVERSE
load("@rules_rust//crate_universe:repositories.bzl", "crate_universe_dependencies")

crate_universe_dependencies()

load("@rules_rust//crate_universe:defs.bzl", "crates_repository", "crate")

crates_repository(
    name = "crate_index",
    cargo_lockfile = "//:Cargo.lock",
    lockfile = "//:cargo-bazel-lock.json",
    manifests = [
        "//:Cargo.toml",
        "//:pkg/rust/src/grpc_client_lib/Cargo.toml",
    ],
)

load("@crate_index//:defs.bzl", "crate_repositories")

crate_repositories()
########################################################################################################################
