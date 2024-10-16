load("@io_bazel_rules_scala//scala:scala.bzl", "scala_binary")
load("@rules_oci//oci:defs.bzl", "oci_image", "oci_load", "oci_push")
load("@rules_pkg//:pkg.bzl", "pkg_tar")

def docker_image(application_name, main_class, deps = [], additional_jvm_opts = []):
    return scala_binary(
        name = "app",
        main_class = main_class,
        deps = deps,
    ), pkg_tar(
        name = "app_layer",
        srcs = [":app_deploy.jar"],
    ), oci_image(
        name = "image",
        base = "@java_temurin",
        entrypoint = [
            "java",
        ] + additional_jvm_opts + [
            "-jar",
            "/app_deploy.jar",
        ],
        tars = [":app_layer"],
    ), oci_load(
        name = "local_image",
        image = ":image",
        repo_tags = ["{app}:latest".format(app = application_name)],
    ), oci_push(
        name = "push",
        image = ":image",
        repository = "docker.io/" + application_name,
    )
