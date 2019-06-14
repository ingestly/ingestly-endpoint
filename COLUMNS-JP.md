# カラムリファレンス

|フィールド名|タイプ|説明|
|:----|:----|:----|
|timestamp|TIMESTAMP|アクション（レコード）のUTCライムスタンプ|
|action|STRING|アクションの名前。基本的に動詞|
|category|STRING|アクションの対象物。基本的に名詞|
|request_id|STRING|SHA256ハッシュで生成されたレコードのユニークID|
|ingestly_id|STRING|デバイス（ブラウザ）を識別するためのユニークID|
|root_id|STRING|ページビューの中で発生したイベントを集約するための、ページビューイベントに対するユニークID|
|since_init_ms|INTEGER|SDKの初期化からの経過ミリ秒|
|since_prev_ms|INTEGER|直前のイベントからの経過ミリ秒|
|client_ip|STRING|訪問者のIPアドレス|
|user_agent|STRING|訪問者のUser-Agent|
|user_id|STRING||
|user_status|STRING||
|user_attr|STRING||
|page_url|STRING||
|page_referrer|STRING||
|page_title|STRING||
|page_attr|STRING||
|content_id|STRING||
|content_headline|STRING||
|content_status|STRING||
|content_attr|STRING||
|viewport_height|FLOAT||
|viewport_width|FLOAT||
|screen_height|FLOAT||
|screen_width|FLOAT||
|screen_orientation|STRING||
|device_type|STRING||
|device_os|STRING||
|device_platform|STRING||
|timing_interactive|INTEGER||
|timing_dcl|INTEGER||
|timing_complete|INTEGER||
|page_height|FLOAT||
|scroll_depth|FLOAT||
|scroll_unit|STRING||
|read_rate|FLOAT||
|read_text_length|FLOAT||
|read_content_height|FLOAT||
|click_tag|STRING||
|click_id|STRING||
|click_class|STRING||
|click_path|STRING||
|click_link|STRING||
|click_attr|STRING||
|media_src|STRING||
|media_current_time|FLOAT||
|media_duration|FLOAT||
|media_played_percent|FLOAT||
|media_attr|STRING||
|campaign_code|STRING||
|campaign_name|STRING||
|campaign_source|STRING||
|campaign_medium|STRING||
|campaign_term|STRING||
|campaign_content|STRING||
|url_protocol|STRING||
|url_hostname|STRING||
|url_pathname|STRING||
|url_search|STRING||
|url_hash|STRING||
|url_query|STRING||
|referrer_protocol|STRING||
|referrer_hostname|STRING||
|referrer_pathname|STRING||
|referrer_search|STRING||
|referrer_hash|STRING||
|referrer_query|STRING||
|custom_attr|STRING||
|is_tls|BOOLEAN||
|is_ipv6|BOOLEAN||
|request_accept_language|STRING||
|request_accept_charset|STRING||
|request_referer|STRING||
|geo_continent_code|STRING||
|geo_region|STRING||
|geo_country_name|STRING||
|geo_country_code|STRING||
|geo_city|STRING||
|geo_latitude|FLOAT||
|geo_longitude|FLOAT||
|geo_gmt_offset|STRING||
|geo_conn_speed|STRING||
|server_datacenter|STRING||
|server_region|STRING||