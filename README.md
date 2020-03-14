# semrel-calc

Version Calculator for Semantic Release. Calculate next version with current version and commit type list.

```sh
$ cat <<EOF | semrel-calc 1.1.1
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

## Test

```sh
nimble test
```

## References

- [Tiny your cli utilities in pure Nim - githu.com](https://github.com/jiro4989/yourutils)
- [NimでオレオレCLIツールを作った - Qiita](https://qiita.com/jiro4989/items/14709e35ef46189a6704)
- [NimでGitHubのリポジトリ検索ツールを作ってみた](https://blog.mamansoft.net/2018/04/22/nim-github-search-tool/)
