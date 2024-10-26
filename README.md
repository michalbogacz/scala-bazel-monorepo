# Scala Bazel Monorepo
An example of a monorepo using Bazel and Scala, demonstrating how to structure and manage multiple Scala microservices with fast efficient builds, testing, docker image building and more.

1. [Features](#features)
   1. [Cache](#cache)
   2. [Commons](#commons)
   3. [Tests speed](#tests-speed)
   4. [Tests types](#tests-types)
   5. [Formatting](#formatting)
   6. [Docker](#docker)
   7. [Scripts](#scripts)
   8. [CI](#ci)
2. [IDE](#ide)
3. [Dependencies](#dependencies)
4. [Multilanguage](#multilanguage)

## Features
Although this project is just an example, it can be used as a template for Scala Monorepo with Bazel.

A list of features presented in this repository is below table:

| Feature          | Description                                                             | Link                        |
|------------------|-------------------------------------------------------------------------|-----------------------------|
| Fast compilation | Bazel is caching all compiled parts and on recompile what is needed     | [Cache](#cache)             |
| Commons          | Parts of codes shared by many services                                  | [Commons](#commons)         |
| Fast tests       | Bazel runs only tests that are needed                                   | [Tests speed](#tests-speed) |
| Test separation  | Different types of tests can be introduced to test in required ways     | [Tests types](#tests-types) |
| Formatting       | Required for devs, and tested on CI                                     | [Formatting](#formatting)   |
| Docker           | Included creation of docker image for services                          | [Docker](#docker)           |
| Scripts          | Scripts can be integrated into monorepo and use parts of implementation | [Scripts](#scripts)         |
| CI               | Simple PR build test                                                    | [CI](#ci)                   |

### Cache
Bazel is only rebuilding parts for application that were changed.
You changed only one service and need to create new [docker image](#docker)? Then Bazel will only build this one service, not a whole monorepo. 
Cache can also be included in [CI](.github/workflows/pr.yml) for faster build.

Moreover, cache can be shared by many CI jobs and even remote execution is possible. This is described in [official docs](https://bazel.build/remote/rbe)

### Commons
The main strength of monorepo is a possibility of sharing code. 
You don't need "commons libraries", everything can be inside repository and compiled as one project. This ensures consistency.

This repository shows such approach with this structure:
```
├── projects
│   ├── commons
│   │   └── init-log
│   ├── service-1
|   └── service-2
```
`service-1` and `service-2`, both depend on `commons/init-log`. Such deduplicated code ensures consistency across different services.
Bazel ensures all dependencies of commons (service) are recompiled when commons are changed.

What else can be in the commons? Here are few examples:
- code which needs to be used in all services, like authorization
- schemas for queues like Kafka Avro schema or Protobuf
- contracts like API schemas
- in rare cases, you can even share DB model for main service and migration service

### Tests speed
When you run tests second without any changes you can see the following result

```bash 
> bazel test --test_tag_filters=unit  //...                        
INFO: Analyzed 27 targets (0 packages loaded, 12 targets configured).
INFO: Found 24 targets and 3 test targets...
INFO: Elapsed time: 0.124s, Critical Path: 0.00s
INFO: 1 process: 1 internal.
INFO: Build completed successfully, 1 total action
//projects/commons/init-log/src/test:tests                      (cached) PASSED in 0.6s
//projects/service-1/src/test:tests                             (cached) PASSED in 0.6s
//projects/service-2/src/test:tests                             (cached) PASSED in 0.5s

Executed 0 out of 3 tests: 3 tests pass.
```
In the above case, Bazel didn't even run tests, it already had information that nothing had changed.

After you change some files in the code (for example "service-1"), Bazel will only run related tests.
This greatly improves testing speed.
```bash
> bazel test --test_tag_filters=unit  //...                        
INFO: Analyzed 27 targets (0 packages loaded, 0 targets configured).
INFO: Found 24 targets and 3 test targets...
INFO: Elapsed time: 1.526s, Critical Path: 1.41s
INFO: 11 processes: 1 internal, 8 darwin-sandbox, 1 local, 1 worker.
INFO: Build completed successfully, 11 total actions
//projects/commons/init-log/src/test:tests                      (cached) PASSED in 0.6s
//projects/service-2/src/test:tests                             (cached) PASSED in 0.5s
//projects/service-1/src/test:tests                                      PASSED in 0.7s

Executed 1 out of 3 tests: 3 tests pass.
```

Note: If you don't need this caching, you can always use `--cache_test_results=no` to force run of all tests.

### Tests types
In this repository, tests are separated into two types

#### 1. Unit tests
Type of tests that can be run concurrently

Run with:
```bash
bazel test --test_tag_filters=unit  //...
```

#### 2. Integration tests
Type of tests that cannot be run concurrently (e.g. tests that are using shared DB)

Run with:
```bash
bazel test --test_tag_filters=integration  //...
```

#### 3. Other?
Test definitions can be found in [test.bzl](tools/test.bzl).
Bazel does not limit tje number of types of tests. If you need another type of test like E2E, you can introduce a new type.

### Formatting
Code can be formatted with
```bash
./tools/scalafmt
```

Formatting is also tested in [CI](.github/workflows/pr.yml)

**Comment**: Scalafmt is "goto" tool for formatting Scala code. Yet, including scalafmt in rules_scala is complicated. E.g. execution requires for all targets use `<TARGET>.format` which is hard to execute for all targets.
That's why I decided to use [standalone](https://scalameta.org/scalafmt/docs/installation.html#standalone) version of scalafmt.
Alternative can be [rules_lint](https://github.com/aspect-build/rules_lint)

### Docker
Docker images are built using rules_oci. 
Each service build file has extension docker_image, which points to [oci.bzl](tools/oci.bzl)

Local image build:
```bash
bazel run //projects/service-1/src/main:local_image
```

Local image test
```bash
docker run --rm service1:latest 
```

Push of image
```bash
bazel run //projects/service-1/src/main:push
```

### Scripts
Scripts can be embedded into monorepo. This makes possible to reuse existing code which reduces risk of scripts being outdated.
Additionally, scripts can be written in the same language as services (in this repository - Scala) which reduces **cognitive load** for developers.
Execution (and compilation) of scripts is fast because, even with empty repo bazel will only compile what is needed to run script.

To execute the example script use
```bash
bazel run //projects/scripts:manualInit -- myArg1 myArg2
```

Check [scripts readme](projects/scripts/README.md) to get more details.

### CI
This repository also contains a simple pull request check [pr.yml](.github/workflows/pr.yml)
To make it faster, it also uses a persistent cache.

## IDE


## Dependencies
The below table shows where you can find which versions for dependencies

| Dependency    | Place                                                 |
|---------------|-------------------------------------------------------|
| Java version  | [.bazelrc](.bazelrc)                                  |
| Scala version | [WORKSPACE.bazel](WORKSPACE.bazel) in `scala_version` |
| Libraries     | [Module.bazel](MODULE.bazel)                          |

## Multilanguage
Despite this repository is not providing example for many languages, it's possible to incorporate many languages in one project.
For example in this project I could add frontend or microservices in many languages (GoLang, Java, C++....).
