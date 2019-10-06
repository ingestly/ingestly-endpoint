# Ingestly Endpoint

- [英語ドキュメントはこちら / English Document available here](./README.md)
- [カラムリファレンスはこちら](https://github.com/ingestly/ingestly-docs/blob/master/COLUMNS-JP.md)

## Ingestlyって?

**Ingestly** はビーコンをGoogle BigQueryに投入するためのシンプルなツールです。デジタルマーケターやフロントエンド開発者はサービス上でのユーザーの動きを、制約やサンプリングせず、リアルタイムに、データの所有権を持ち、合理的なコストの範囲内で計測したいと考えます。市場には多種多様なツールがありますが、いずれも高額で、動作が重く、柔軟性に乏しく、専用のUIで、`document.write`のような昔っぽい技術を含むSDKを利用することを強いられます。

Ingestlyは、Fastlyを活用してフロントエンドからGoogle BigQueryへのデータ投入することにフォーカスしています。
また、Ingestlyは同じFastlyのserviceの中で既存のウェブサイトに対してシームレスに導入でき、自分自身のアナリティクスツールを保有できITPは問題にはなりません。

**Ingestlyが提供するのは:**

- 完全にサーバーレス。IngestlyのインフラはFastlyとGoogleが管理するので、運用リソースは必要ありません。
- ほぼリアルタイムのデータがGoogle BigQueryに。ユーザーの動きから数秒以内に最新のデータを得ることができます。
- ビーコンに対する最速のレスポンスタイム。エンドポイントにバックエンドはなく、Fastlyのグローバルなエッジノードが応答、レスポンスはHTTP 204でSDKは非同期リクエストを用います。
- BigQueryに直接連携。複雑な連携設定をする必要はなく、データをバッチでエクスポート・インポートする必要もありません。
- 簡単に始められます。既にFastlyとGCPのトライアルアカウントをお持ちでしたら、2分以内にIngestlyを使い始められます。
- WebKitのITPとの親和性。エンドポイントはセキュアフラグ類付きのファーストパーティCookieを発行します。

## セットアップ

BigQueryとElasticsearchのいずれか、または両方のデータベースをログ用に利用できます。 Fastlyは同じ構成に対して複数のログストリーミングをサポートしています。
BigQueryはSQLをサポートし、巨大なログに対して高速にクエリーできます。Elasticsearchは極めて柔軟なスキーマレスのデータ構造をサポートします。
もしカスタムデータ（ `*_attr` 系の変数）を頻繁に利用する場合、またはKibanaの優れた可視化機能を利用したい場合、Elasticsearchが最適です。
もし巨大なサイトからの膨大なレコード数を受け取る場合、またはData Studioを利用したい場合、BigQueryはより高い性能を合理的なコストの範囲内で提供します。

### 前提条件
- [Google Cloud Platform](https://cloud.google.com/) のアカウントと、Ingestlyで使うプロジェクト
- [Fastly](https://www.fastly.com/signup) のアカウントと、Ingestlyで使う service
- エンドポイントは、指定したドメイン下に `ingestlyId` という名前のCookieを発行します

*GCPプロジェクトとFastlyのserviceはIngestly用に作ることも、既存のものを使うこともできます*

### Google Cloud Platform

#### Fastly用のサービスアカウントを作成
1. GCPコンソールから `IAMと管理` → `サービスアカウント` を開きます。
2. `ingestly`等のサービスアカウントを作成し、`BigQuery` → `BigQuery データオーナー` 権限を付与します。
3. キーを作成し、JSON形式でダウンロードします。
4. 今ダウンロードしたJSONを開き、`private_key` と `client_email` を控えておきます。

#### ログデータ用のテーブルをBigQueryに作成
1. GCPコンソールから `BigQuery` を開きます。
2. まだデータセットをお持ちで無ければ、`Ingestly` のようなデータセットを作成します。
3. `logs` のような任意の名前のテーブルを作成し、スキーマ欄の `テキストとして編集` を有効にします。（テーブル名を控えておきます）
4. このリポジトリの `BigQuery/table_schema` ファイルを開き、中身をコピー、テーブル作成画面のスキーマのテキストボックスにペーストします。
5. `パーティションとクラスタの設定` 欄でパーティショニングに `timestamp` カラムを選択します。
6. テーブル作成を完了します。

### Elasticsearch

#### Fastly用のユーザーを作成
1. Kibana UIを開きます。
2. `Management > Security > Roles` に進みます。
3. 右上の `Create role` ボタンを押します。
4. ロール名を `Ingestly` とします。
5. `Indices` フィールドに `ingestly` と手動で入力します
6. `Privileges` フィールドで、`create_index`, `create`, `index`, `read`, `write` そして `monitor` を選択し、保存します。
7. `Management > Security > Users` に進みます。
8. 右上の `Create user` ボタンを押します。
9. ユーザー名を `Ingestly` とし、個々のフィールドをお好みで記入します。
10. ロールのリストから `Ingestly` を選択し、保存します。

#### Elasticsearchにマッピングテンプレートを設置
1. `Dev Tools` に移動します。
2. Dev Tools コンソールの1行目に `PUT _template/ingestly` と入力します。
3. `Elasticsearch/mapping_template.json` ファイルを開き、中身をDev Tools コンソールの2行目にコピー＆ペーストします。
4. 1行目の三角形のアイコンをクリックします（コマンドを実行）

もし上記のプロセスの実行時に `Custom Analyzer` に関するエラーメッセージが見える場合、以下の選択肢の内の1つを選択します。

A. 自然言語解析プラグインをElasticsearchに追加する。 `analysis-kuromoji` と `analysis-icu` が推奨。
B. Analyzerを無効化するため、 `analysis` セクション（22行目〜40行目）を `Elasticsearch/mapping_template.json` から削除する。

#### インデックスパターンを作成
1. `Management > Kibana > Index Patterns` に移動します。
2. 右上の `Create index pattern` ボタンを押します。
3. `Index Pattern` フィールドに `ingestly` と入力し、 `Next step` をクリックします。
4. `Time Filter field name` で `timestamp` を選択し、 `Create index pattern` をクリックします。


### Fastly

#### Custom VCL
1. このリポジトリの `ingestly.vcl` ファイルを開き、`cookie_domain` の値をCookieのドメインが一致するように変更し、保存します。
2. 設定する service のCONFIGUREページから `Custom VCL`を開きます。
3. `Upload a VCL file` ボタンをクリックし、`Ingestly` 等の名前を指定、 `ingestly.vcl` を選択してファイルをアップロードします。

#### Google BigQuery と連携
1. CONFIGUREページから `Logging` を開きます。
2. `CREATE ENDPOINT` をクリックし、 `Google BigQuery` を選択します。
3. ハイライトされている `CONDITION` の近くにある `attach a condition.` リンクを開き、`CREATE A NEW RESPONSE CONDITION` を選択します。
4. `Data Ingestion` のような名前を入力し、 `Apply if…` には `(resp.status == 204 && req.url ~ "^/ingestly-ingest/(.*?)/\?.*" || resp.status == 200 && req.url ~ "^/ingestly-sync/(.*?)/\?.*")` をセットします。
5. 各設定項目に情報を：
    - `Name` ： お好きな名前
    - `Log format` ： このリポジトリの `BigQuery/log_format` ファイルの中身をコピー＆ペースト
    - `Email` ： GCP認証情報のJSONファイルの `client_email` の値
    - `Secret key` ： GCP認証情報のJSONファイルの `private_key` の値
    - `Project ID` ： GCPでのプロジェクトID
    - `Dataset` ： Ingestly用に作成したデータセットの名前（例： `Ingestly` ）
    - `Table` ： Ingestly用に作成したテーブル名（例： `logs` ）
    - `Template` ： このフィールドは空にできますが、 `%Y%m%d` のように指定すれば時系列テーブルに分割できます。
6. `CREATE` をクリックして設定を完了します。

#### Elasticsearch と連携
1. CONFIGUREページから `Logging` を開きます。
2. `CREATE ENDPOINT` をクリックし、 `Elasticsearch` を選択します。
3. ハイライトされている `CONDITION` の近くにある `attach a condition.` リンクを開き、`CREATE A NEW RESPONSE CONDITION` を選択します。
4. `Data Ingestion` のような名前を入力し、 `Apply if…` には `(resp.status == 204 && req.url ~ "^/ingestly-ingest/(.*?)/\?.*" || resp.status == 200 && req.url ~ "^/ingestly-sync/(.*?)/\?.*")` をセットします。
5. 各設定項目に情報を：
    - `Name` : お好きな名前
    - `Log format` : このリポジトリの `Elasticsearch/log_format` ファイルの中身をコピー＆ペースト
    - `URL` : Elasticsearch クラスターのエンドポイントURL.
    - `Index` : Elasticsearch のインデックス名。 `ingestly` をセット
    - `BasicAuth user` : Elasticsearchの認証に用いる名前。 `Ingestly` をセット
    - `BasicAuth password` : Elasticsearch クラスター上の `Ingestly` ユーザーのパスワードをセット
6. `CREATE` をクリックして設定を完了します。

## 次のステップ
- ビーコンを受信する準備が整いました。[Ingestly Client JS](https://github.com/ingestly/ingestly-client-js) をウェブサイトにインストールできます。
