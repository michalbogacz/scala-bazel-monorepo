# Example script
Scripts can integrate with other parts of monorepo and can reuse any code.
Additionally, it's also written in Scala so it's consistent with whole project.

"Scripts" directory can contain many different scripts. 

This example script also shows how to pass arguments with Bazel
```bash
bazel run //projects/scripts:manualInit -- myArg1 myArg2
```
