# Scripts

Scripts can depend on any part of monorepo. In this example, they depend on `commons`
But scripts can also depend on services and use their code.

File [BUILD.bazel](BUILD.bazel) can contain many `scala_binary` to easily reference additional scrips.
The structure of scripts might look strange, but it shows that Bazel does not restrict your decision on how you organize code.
