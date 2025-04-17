load("@rules_scala//scala:scala_toolchain.bzl", "scala_toolchain")

scala_toolchain(
    name = "custom_scala_toolchain_impl",
    scalacopts = [
        "-Ywarn-unused",
    ],
    strict_deps_mode = "error",
    unused_dependency_checker_mode = "warn",
)

toolchain(
    name = "custom_scala_toolchain",
    toolchain = ":custom_scala_toolchain_impl",
    toolchain_type = "@rules_scala//scala:toolchain_type",
    visibility = ["//visibility:public"],
)
