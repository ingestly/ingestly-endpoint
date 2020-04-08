CREATE EXTERNAL TABLE IF NOT EXISTS mydatabase.ingestly (
  `timestamp` timestamp,
  `action` string,
  `category` string,
  `request_id` string,
  `ingestly_id` string,
  `session_id` string,
  `is_id_new` boolean,
  `is_session_new` boolean,
  `root_id` string,
  `since_init_ms` bigint,
  `since_prev_ms` bigint,
  `client_ip` string,
  `user_agent` string,
  `user_id` string,
  `user_status` string,
  `user_attr` string,
  `page_url` string,
  `page_referrer` string,
  `page_title` string,
  `page_attr` string,
  `content_id` string,
  `content_headline` string,
  `content_status` string,
  `content_attr` string,
  `viewport_height` double,
  `viewport_width` double,
  `screen_height` double,
  `screen_width` double,
  `screen_orientation` string,
  `device_type` string,
  `device_os` string,
  `device_platform` string,
  `timing_interactive` bigint,
  `timing_dcl` bigint,
  `timing_complete` bigint,
  `timing_elapsed_ms` bigint,
  `navigation_type` bigint,
  `navigation_redirect_count` bigint,
  `page_height` double,
  `scroll_depth` double,
  `scroll_unit` string,
  `read_target_index` bigint,
  `read_target_id` string,
  `read_text_start_with` string,
  `read_rate` double,
  `read_text_length` double,
  `read_content_height` double,
  `read_attr` string,
  `click_tag` string,
  `click_id` string,
  `click_class` string,
  `click_path` string,
  `click_link` string,
  `click_text` string,
  `click_attr` string,
  `media_src` string,
  `media_current_time` double,
  `media_duration` double,
  `media_played_percent` double,
  `media_attr` string,
  `form_name` string,
  `form_items` string,
  `form_first_item` string,
  `form_last_item` string,
  `form_started_since_init_ms` bigint,
  `form_ended_since_init_ms` bigint,
  `form_duration_ms` bigint,
  `form_attr` string,
  `campaign_code` string,
  `campaign_name` string,
  `campaign_source` string,
  `campaign_medium` string,
  `campaign_term` string,
  `campaign_content` string,
  `url_protocol` string,
  `url_hostname` string,
  `url_pathname` string,
  `url_search` string,
  `url_hash` string,
  `url_query` string,
  `referrer_protocol` string,
  `referrer_hostname` string,
  `referrer_pathname` string,
  `referrer_search` string,
  `referrer_hash` string,
  `referrer_query` string,
  `survey_name` string,
  `survey_result` string,
  `o2o_name` string,
  `o2o_scanner` string,
  `o2o_key` string,
  `o2o_result` string,
  `custom_attr` string,
  `is_tls` boolean,
  `is_ipv6` boolean,
  `request_accept_language` string,
  `request_accept_charset` string,
  `request_referer` string,
  `geo_continent_code` string,
  `geo_region` string,
  `geo_country_name` string,
  `geo_country_code` string,
  `geo_city` string,
  `geo_latitude` double,
  `geo_longitude` double,
  `geo_gmt_offset` string,
  `geo_conn_speed` string,
  `server_datacenter` string,
  `server_region` string 
) PARTITIONED BY (
  date date 
)
ROW FORMAT SERDE 'org.openx.data.jsonserde.JsonSerDe'
WITH SERDEPROPERTIES (
  'serialization.format' = '1'
) LOCATION 's3://my-bucket/my-path/'
TBLPROPERTIES ('has_encrypted_data'='false');