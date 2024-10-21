# Scripts

Scripts can depend on any part of monorepo. In this example they depend on `commons`
You need in script part of service? Access to DB with real code repository? It can be easily done.

File [BUILD.bazel](BUILD.bazel) can contain many `scala_binary` to easier reference additional scrips.
Structure of scripts might look strange, but it shows that Bazel does not restrict your decision on how you organize code.
