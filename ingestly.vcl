table metadata {
  "cookie_domain": "example.com",
  "cookie_lifetime": "31536000"
}

table apikeys {
  # List API keys which you want to accept. (change to "false" when you disable the existing keys)
  "2ee204330a7b2701a6bf413473fcc486": "true"
}

sub vcl_recv {
#FASTLY recv
  if(table.lookup(apikeys, subfield(req.url.qs, "key", "&")) != "true"){
    # Invalid API Key (if you configure Fastly to use only for Ingestly, use the below.)
    # error 401 "Unauthorized";
  }else{
    if(req.url ~ "^/ingestly-ingest/(.*?)/\?.*"){
      # Valid Ingestion
      error 204 "No Content";
    }else if(req.url ~ "^/ingestly-sync/(.*?)/\?.*"){
      # Valid Sync
      error 200 "OK";
    }else{
      # Invalid Request (if you configure Fastly to use only for Ingestly, use the below.)
      # error 400 "Bad Request";
    }
  }
}

sub vcl_error {
#FASTLY error
  declare local var.cookie_domain STRING;
  declare local var.cookie_lifetime STRING;
  declare local var.ingestly_id STRING;

  set var.cookie_domain = table.lookup(metadata, "cookie_domain");
  set var.cookie_lifetime = table.lookup(metadata, "cookie_lifetime");

  if(req.url ~ "^/ingestly-ingest/(.*?)/\?.*" || req.url ~ "^/ingestly-sync/(.*?)/\?.*"){
    if(req.http.Cookie:ingestlyId){
      set var.ingestly_id = req.http.Cookie:ingestlyId;
    }else{
      set var.ingestly_id = subfield(req.url.qs, "ingestlyId", "&");
    }

    if (obj.status == 200) {
      set obj.status = 200;
      set obj.response = "OK";
      set obj.http.Content-Type = "application/json";
      synthetic {"
      {"id":""} + var.ingestly_id + {"""}{"}"}{""};
    }

    if (obj.status == 204) {
      set obj.status = 204;
      set obj.response = "No Content";
    }

    set obj.http.Access-Control-Allow-Origin = "*";
    set obj.http.Set-Cookie  = "ingestlyId=" + var.ingestly_id + "; Max-Age=" + var.cookie_lifetime + "; Domain=" + var.cookie_domain + "; Path=/; SameSite=Lax; HttpOnly; Secure;";
    set obj.http.Cache-Control = "no-store";
    return (deliver);
  }
}
