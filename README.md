# ttm
A CLI tool to manage tmp dirs for throwaway work

## Feature plan
ttm でセッションをスタート。exit したら即座にアーカイブ

```bash
# start session
ttm

# exit
exit
```

## Commands
```bash
➜ ttm --help
ttm
Version: 0.0.4

USAGE:
  ttm [OPTIONS]

A CLI tool to manage tmp dirs for throwaway work

COMMANDS:
  ls      list tmp dirs
  x       exec in tmp dir
  pin     rename and keep tmp dir
  rm      remove tmp dir
  prune   remove archived tmp dirs

OPTIONS:
  -h, --help            Show this help output.
      --color <VALUE>   When to use colors (*auto*, never, always).
```

### ls
過去のセッションをリスト

```bash
$ ttm ls
[q] Quit, [Enter] Start shell

 > 202510251849-ax52t │
   202510251857-iz3ws │
   202510191513-o7roe │
```

- 今の時点ではすべてのユースケースを考慮しない
- セッションが終わってもディレクトリを圧縮しない

### pin
```bash
ttm pin last
```

## Development
```bash
zig build run
zig build test
```
