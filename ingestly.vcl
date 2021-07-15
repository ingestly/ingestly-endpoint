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
    if(req.url ~ "^\.well-known\/attribution-reporting\/.*" || req.url ~ "^\.well-known\/private-click-measurement\/.*"){
      # Attribution Reporting & Private Click Measurement
      error 200 "OK";
    }else{
      # Invalid API Key (if you configure Fastly to use only for Ingestly, use the below.)
      # error 401 "Unauthorized";
    }
  }else{
    if(req.url ~ "^/ingestly-ingest/(.*?)/\?.*" || req.url ~ "^/ingestly-consent/(.*?)/\?.*" || req.url ~ "^/ingestly-bulk/(.*?)/\?.*"){
      # Valid Ingestion
      error 204 "No Content";
    }else if(req.url ~ "^/ingestly-sync/(.*?)/\?.*"){
      # Valid Sync (< 1.0.0)
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
  declare local var.session_id STRING;

  set var.cookie_domain = table.lookup(metadata, "cookie_domain");
  set var.cookie_lifetime = table.lookup(metadata, "cookie_lifetime");

  if(req.url ~ "^/ingestly-ingest/(.*?)/\?.*" || req.url ~ "^/ingestly-bulk/(.*?)/\?.*"){
    # Data Collection

    # If a visitor accepted Cookies... (or ck flag does not exists with older SDK)
    if(subfield(req.url.qs, "ck", "&") != "false"){

      # Set headers
      set obj.http.Access-Control-Allow-Origin = "*";
      set obj.http.Cache-Control = "no-store";

      # Define Ingestly ID
      if(req.http.Cookie:ingestlyId){
        set var.ingestly_id = req.http.Cookie:ingestlyId;
      }else{
        set var.ingestly_id = subfield(req.url.qs, "rootId", "&");
        add obj.http.Set-Cookie = "ingestlyId=" + var.ingestly_id
                                + "; Max-Age=" + var.cookie_lifetime
                                + "; Path=/; SameSite=Lax; HttpOnly; Secure;";
      }

      if(req.url ~ "^/ingestly-ingest/(.*?)/\?.*"){
        # Define Session ID
        if(req.http.Cookie:ingestlySes){
          set var.session_id = req.http.Cookie:ingestlySes;
        }else{
          set var.session_id = subfield(req.url.qs, "rootId", "&");
        }
        add obj.http.Set-Cookie = "ingestlySes=" + var.session_id
                                + "; Path=/; SameSite=Lax; HttpOnly; Secure;";
      }

    }

    return (deliver);

  }elseif(req.url ~ "^/ingestly-sync/(.*?)/\?.*"){
    # Return Ingestly ID in JSON if HTTP200 (< 1.0.0)

    # Define Ingestly ID
    if(req.http.Cookie:ingestlyId){
      set var.ingestly_id = req.http.Cookie:ingestlyId;
    }else{
      set var.ingestly_id = subfield(req.url.qs, "ingestlyId", "&");
    }

    # Return a response
    set obj.http.Content-Type = "application/json";
    synthetic {"{"id":""} + var.ingestly_id + {"""}{"}"}{""};
    set obj.http.Access-Control-Allow-Origin = "*";
    set obj.http.Set-Cookie  = "ingestlyId=" + var.ingestly_id + "; Max-Age=" + var.cookie_lifetime + "; Domain=" + var.cookie_domain + "; Path=/; SameSite=Lax; HttpOnly; Secure;";
    set obj.http.Cache-Control = "no-store";
    return (deliver);
    
  }elseif(req.url ~ "^/ingestly-consent/(.*?)/\?.*"){
    # Consent Management

    # Set headers
    set obj.http.Access-Control-Allow-Origin = "*";
    set obj.http.Cache-Control = "no-store";

    # Cookie Opt-out
    if(subfield(req.url.qs, "dc", "&") == "1"){
      add obj.http.Set-Cookie = "ingestlyId=0; Max-Age=0; Path=/; SameSite=Lax; HttpOnly; Secure;";
      add obj.http.Set-Cookie = "ingestlySes=0; Max-Age=0; Path=/; SameSite=Lax; HttpOnly; Secure;";
    }

    # Save Consent Information
    if(subfield(req.url.qs, "ap", "&")){
      add obj.http.Set-Cookie = "ingestlyConsent=" + urldecode(subfield(req.url.qs, "ap", "&"))
                              + "; Max-Age=" + var.cookie_lifetime
                              + "; Domain=" + var.cookie_domain
                              + "; Path=/; SameSite=Lax; Secure;";
    }

    return (deliver);
  }
}
