#コマンド
```
diary.pl <username> add_d <diary_title>
diary.pl <username> add_e <diary_id> <entry_title> <body>
diary.pl <username> list_d [limit, デフォルトは10]
diary.pl <username> list_e <diary_id> [limit, デフォルトは10]
diary.pl <username> delete_e <diary_id> <entry_id> 
diary.pl <username> update_e <entry_id> <entry_title> <body>
```

#URI
```
日記の一覧表示 GET /
記事の一覧表示 GET /diaries/diary_id
記事の追加 POST /entries
記事の削除 POST /entries/entry_id/delete
記事の更新 POST /entries/entry_id/update
```

#JSON-API
```
日記の一覧を取得 GET /api/diaries
記事の一覧を取得 GET /api/diaries/diary_id
記事の追加 POST /api/entries
    POSTのJSONフォーマット
    {
        'diary_id' : xxx,
        'title' : xxx,
        'body' : xxx
    }
```
