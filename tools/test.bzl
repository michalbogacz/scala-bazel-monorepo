load("@io_bazel_rules_scala//scala:scala.bzl", "scala_test")

def unit_test(**kwargs):
    set_default_name(kwargs)
    assign_if_empty(kwargs, "size", "small")
    add_tags(kwargs, "unit")
    return scala_test(**kwargs)

# "exclusive" to not run these tests at the same time
# https://bazel.build/reference/be/common-definitions#common-attributes-tests
def integration_test(**kwargs):
    set_default_name(kwargs)
    assign_if_empty(kwargs, "size", "small")
    add_tags(kwargs, "exclusive", "integration")
    return scala_test(**kwargs)

def set_default_name(kwargs):
    _, _, target_name = native.package_name().rpartition("/")
    if "name" not in kwargs:
        kwargs["name"] = target_name

def assign_if_empty(kwargs, key, value):
    if key not in kwargs:
        kwargs[key] = value
    return kwargs[key]

def add_tags(kwargs, *args):
    assign_if_empty(kwargs, "tags", []).extend(args)
