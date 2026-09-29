load("@rules_oci//oci:defs.bzl", "oci_image", "oci_load", "oci_push")
load("@rules_pkg//:pkg.bzl", "pkg_tar")
load("@rules_scala//scala:scala.bzl", "scala_binary")
load("//tools:jvm_layers.bzl", "CLASSPATH_ARGFILE", "jvm_layer_files")

# Third-party jars and first-party jars ship as separate layers instead of one app_deploy.jar layer,
# so a code-only change pushes and pulls only the small first-party layer. See jvm_layers.bzl.
def docker_image(application_name, main_class, deps = [], additional_jvm_opts = []):
    scala_binary(
        name = "app",
        main_class = main_class,
        deps = deps,
    )
    jvm_layer_files(
        name = "deps_files",
        binary = ":app",
        third_party = True,
    )
    pkg_tar(
        name = "deps_layer",
        srcs = [":deps_files"],
    )
    jvm_layer_files(
        name = "app_files",
        binary = ":app",
        third_party = False,
    )
    pkg_tar(
        name = "app_layer",
        srcs = [":app_files"],
    )
    oci_image(
        name = "image",
        base = "@java_temurin",
        entrypoint = [
            "java",
        ] + additional_jvm_opts + [
            "@" + CLASSPATH_ARGFILE,
            main_class,
        ],
        tars = [
            ":deps_layer",
            ":app_layer",
        ],
    )
    oci_load(
        name = "local_image",
        image = ":image",
        repo_tags = ["{app}:latest".format(app = application_name)],
    )
    oci_push(
        name = "push",
        image = ":image",
        repository = "docker.io/" + application_name,
    )
