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

### SubCommands
```bash
# 過去のセッションをリスト
# 左にリストが。選択中のセッションの tree が右に表示される。
# 選択しているときに
# - Enter を押したら exec
# - e を押したらカレントディレクトリへディレクトリをエクスポート
# - r を押したら rm
wtmp ls
```

- 今の時点ではすべてのユースケースを考慮しない
- コマンドの履歴と stdout を出力できるようにしたい
- セッションが終わってもディレクトリを圧縮しない
- 1週間後に削除する

## Commands
```bash
zig build run
zig build test
```
