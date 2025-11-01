# wtmp
A CLI tool to manage tmp dirs for throwaway work

## Feature plan
wtmp でセッションをスタート。exit したら即座にアーカイブ

```bash
# start session
wtmp

# exit
exit
```

### ls
過去のセッションをリスト

```bash
$ wtmp ls

[Enter] Start shell, [r] Remove, [q] Quit

 > 202510251849-ax52t │
   202510251857-iz3ws │
   202510191513-o7roe │
```

- 今の時点ではすべてのユースケースを考慮しない
- セッションが終わってもディレクトリを圧縮しない
- 1週間後に削除する
- exit するときに rm できるようにしたい
  - rm がデフォルトであり、追加操作として pin できるようにする

### pin
```bash
wtmp pin last
```

## Commands
```bash
zig build run
zig build test
```
