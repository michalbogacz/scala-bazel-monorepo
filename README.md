# Scala Bazel Monorepo
An example of a monorepo using Bazel and Scala, demonstrating how to structure and manage multiple Scala microservice with fast efficient builds, testing, docker image building and more.

## Features
Although, this is project is just example, it can be used as template for Scala Monorepo with Bazel.
It contains proposed code structure, testing, formatting, image builds and other. 
List of such features is below table:

| Feature          | Description                                                                                                          | Link                            |
|------------------|----------------------------------------------------------------------------------------------------------------------|---------------------------------|
| Fast compilation | Bazel is caching all compiled parts and on recompile what is needed                                                  | [Cache](#cache)                 |
| Commons          | You have code duplication across service? Or need to share common parts like models? This project shows how to do it | [Commons](#commons)             |
| Fast tests       | Bazel runs only tests that are needed                                                                                | [Tests speed](#tests-speed)     |
| Test separation  | Different types of tests can be introduced to test in required ways                                                  | [Tests types](#tests-types)     |
| Formatting       | Required for devs, and tested on CI                                                                                  | [Formatting](#formatting)       |
| Docker           | Included creation of docker image for services                                                                       | [Docker](#docker)               |

### Cache
Bazel is only rebuilding parts for application that were changed.
You changed only one service and need to [docker image](#docker)? Then Bazel will only build this one service, now whole monorepo. 
Cache can be included in [CI](.github/workflows/pr.yml) for faster build.

What's more, cache can be shared by many CI jobs and even remote execution is possible. This is descried in [official docs](https://bazel.build/remote/rbe)

### Commons
Main strength of monorepo is shared and consistent code. 
You don't need "commons libraries", everything can be inside repository and compiled as one.

This repository shows such approach with this structure:
```
├── projects
│   ├── commons
│   │   └── init-log
│   ├── service-1
|   └── service-2
```
`service-1` and `service-2`, both depend on `commons/init-log` and use it's code to for deduplication.

What else can be in commons? Here are few examples:
- code which needs to be used in all services, like authorization
- schemas for queues like Kafka Avro schema or Protobuf
- API schemas for communication between service
- DB model to be used services (e.g. one main service and other service for migration of data)
- and anything you can imagine

You don't to have separate libraries to share code parts.

### Tests speed
When you run tests second without any changes you can see following result

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
Bazel didn't even run tests, it already had information that nothing was changed.

After you change some files in one of parts, like "service-1", Bazel will only run related tests.
This greatly improve testing speed in monorepo and can be applied to CI.
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
In this repository tests are separated into two types

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
Tests definitions can be found in [test.bzl](tools/test.bzl).
Bazel does not limit number of types of tests. If you need another type of test like E2E, you can introduce new type.

### Formatting
Code should be formatted with
```bash
./tools/scalafmt
```

Formatting is tested in [CI](.github/workflows/pr.yml)

**Comment**: Scalafmt is "goto" tool for formatting Scala code. Yet, included scalafmt in rules_scala is unnecessarily complicated. E.g. execution requires for all targets use `<TARGET>.format` which is hard to execute for all targets.
That's why I decided to use [standalone](https://scalameta.org/scalafmt/docs/installation.html#standalone) version of scalafmt.
Alternative can be [rules_lint](https://github.com/aspect-build/rules_lint)

### Docker
Docker images are build using rules_oci. 
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

## Multilanguage
Despite this repository is not providing example for many languages, it's possible to incorporate many languages in one project.
For example in this project I could add frontend or microservices in many languages (GoLang, Java, C++....).