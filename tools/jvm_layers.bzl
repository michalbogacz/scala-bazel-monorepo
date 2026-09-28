"""Splits a JVM binary's runtime classpath into two image layers instead of one app_deploy.jar layer:
  - third-party jars (Maven, Scala stdlib): large, change only on dependency bumps
  - jars built from this repo, plus the classpath argfile: small, change on every code change
A code-only change then produces a new small layer instead of a new fat-jar one; the third-party
layer keeps its digest, so the registry push and the node pull skip it.

Used by docker_image in oci.bzl, once per layer:
  jvm_layer_files(third_party = True)  -> pkg_tar :deps_layer
  jvm_layer_files(third_party = False) -> pkg_tar :app_layer
The container starts with `java @/app/classpath.txt <main_class>` instead of `java -jar /app_deploy.jar`.
"""

load("@rules_java//java/common:java_info.bzl", "JavaInfo")
load("@rules_pkg//pkg:providers.bzl", "PackageFilesInfo")

# Java argument file: java expands `@/app/classpath.txt` to its contents, i.e. `-cp <jar>:<jar>:...`.
CLASSPATH_ARGFILE = "/app/classpath.txt"

def _dest(jar):
    # Full short_path, because basenames can collide between packages.
    #   projects/commons/init-log/src/main/init-log.jar    -> app/lib/projects/commons/init-log/src/main/init-log.jar
    #   ../rules_jvm_external++maven+maven/.../x-1.0.jar    -> app/lib/rules_jvm_external++maven+maven/.../x-1.0.jar
    # Paths of external jars contain Bazel's canonical repo names, so a Bazel or rules_jvm_external upgrade
    # that renames them changes the third-party layer digest once.
    return "app/lib/" + jar.short_path.removeprefix("../")

def _is_third_party(jar):
    # Jars built in the main repository have an empty workspace name; Maven and toolchain jars do not.
    return jar.owner.workspace_name != ""

def _jvm_layer_files_impl(ctx):
    # Same jars, in the same order, that rules_scala feeds to singlejar for app_deploy.jar.
    # Order matters: for a class present in more than one jar, the JVM loads the first one on the classpath,
    # which is also the copy singlejar keeps in the fat jar.
    jars = ctx.attr.binary[JavaInfo].transitive_runtime_jars.to_list()
    selected = [jar for jar in jars if _is_third_party(jar) == ctx.attr.third_party]
    dest_src_map = {_dest(jar): jar for jar in selected}

    if not ctx.attr.third_party:
        # Lists all jars of both layers. It lives in the first-party layer because any classpath change rewrites it,
        # and it must not invalidate the third-party layer.
        classpath = ctx.actions.declare_file(ctx.label.name + ".classpath.txt")
        ctx.actions.write(classpath, "-cp\n" + ":".join(["/" + _dest(jar) for jar in jars]) + "\n")
        dest_src_map[CLASSPATH_ARGFILE.removeprefix("/")] = classpath

    return [
        # Consumed by pkg_tar srcs; pkg_tar fixes mtimes, so the tar is byte-identical for identical inputs.
        PackageFilesInfo(dest_src_map = dest_src_map, attributes = {"mode": "0644"}),
        DefaultInfo(files = depset(dest_src_map.values())),
    ]

jvm_layer_files = rule(
    implementation = _jvm_layer_files_impl,
    doc = "Runtime jars of a JVM binary, split into third-party jars or first-party jars plus the java classpath argfile.",
    attrs = {
        "binary": attr.label(
            mandatory = True,
            providers = [JavaInfo],
            doc = "scala_binary whose runtime classpath is packaged.",
        ),
        "third_party": attr.bool(
            mandatory = True,
            doc = "True: third-party jars only. False: first-party jars plus the classpath argfile.",
        ),
    },
)
