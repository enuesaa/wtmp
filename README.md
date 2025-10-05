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

過去のセッションを選択して再開。TUI ライクになっちゃうかなあ。
```bash
wtmp history
```

- アセットをエクスポートできるようにしたいが、いったんセッションの中で mv するので代替する
- 今の時点ではすべてのユースケースを考慮しない
- コマンドの履歴と stdout を出力できるようにしたい
- アーカイブは zip にまとめて一定期間保管するイメージ

## Commands
```bash
zig build run
zig build test
```
