# scala-bazel-monorepo
Example monorepo with Scala

## Formatting

Code should be formatted with
```bash
./tools/scalafmt
```

Formatting is tested in [CI](.github/workflows/pr.yml)

**Comment**: Scalafmt is "goto" tool for formatting Scala code. Yet, included scalafmt in rules_scala is unnecessarily complicated. E.g. execution requires for all targets use `<TARGET>.format` which is hard to execute for all targets.
That's why I decided to use [standalone](https://scalameta.org/scalafmt/docs/installation.html#standalone) version of scalafmt.
