# semrel-calc

Version Calculator for Semantic Release. Calculate next version with current version and commit type list.

```sh
$ cat <EOF | semrel-calc 1.1.1
feat(*):
fix(*):
feat(*):
fix(*):
fix(*):
fix(*):
EOF
1.2.0

$
```
