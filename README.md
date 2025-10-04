# wtmp
A CLI tool to manage tmp dirs for throwaway work. ***work in tmp dirs***

## Feature plans

```bash
# start session
wtmp

# exit
exit

wtmp last
wtmp clear

wtmp sh
```

## TODO
- アセットを export するには。
- 今の時点では、すべてのユースケースをカバーする必要ないので一旦いい。
- wtmp でセッションをスタートし exit したら即座にアーカイブ
- コマンドの履歴と stdout を出力できるようにしたい
- アーカイブは zip にまとめて一定期間保管するイメージ

## Commands
```bash
zig build run
zig build test
```
