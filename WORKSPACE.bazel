load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

http_archive(
    name = "io_bazel_rules_scala",
    sha256 = "e734eef95cf26c0171566bdc24d83bd82bdaf8ca7873bec6ce9b0d524bdaf05d",
    strip_prefix = "rules_scala-6.6.0",
    url = "https://github.com/bazelbuild/rules_scala/releases/download/v6.6.0/rules_scala-v6.6.0.tar.gz",
)

load("@io_bazel_rules_scala//:scala_config.bzl", "scala_config")
scala_config(scala_version = "2.13.14")

load("@io_bazel_rules_scala//scala:scala.bzl", "scala_repositories")
scala_repositories(
    overriden_artifacts = {
        # Change both the artifact names and sha256s.
        "io_bazel_rules_scala_scala_library": {
            "artifact": "org.scala-lang:scala-library:{}".format("2.13.14"),
            "sha256": "43e0ca1583df1966eaf02f0fbddcfb3784b995dd06bfc907209347758ce4b7e3",
        },
        "io_bazel_rules_scala_scala_compiler": {
            "artifact": "org.scala-lang:scala-compiler:{}".format("2.13.14"),
            "sha256": "17b7e1dd95900420816a3bc2788c8c7358c2a3c42899765a5c463a46bfa569a6",
        },
        "io_bazel_rules_scala_scala_reflect": {
            "artifact": "org.scala-lang:scala-reflect:{}".format("2.13.14"),
            "sha256": "8846baaa8cf43b1b19725ab737abff145ca58d14a4d02e75d71ca8f7ca5f2926",
        },
    },
)

load("@rules_proto//proto:repositories.bzl", "rules_proto_dependencies", "rules_proto_toolchains")
rules_proto_dependencies()
rules_proto_toolchains()

load("@io_bazel_rules_scala//scala:toolchains.bzl", "scala_register_toolchains")
scala_register_toolchains()

load("@io_bazel_rules_scala//testing:scalatest.bzl", "scalatest_repositories", "scalatest_toolchain")
scalatest_repositories()
scalatest_toolchain()
