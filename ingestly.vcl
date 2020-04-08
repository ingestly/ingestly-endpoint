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
    if(req.url ~ "^/ingest/(.*?)/\?.*" || req.url ~ "^/consent/(.*?)/\?.*"){
      # Valid Ingestion
      error 204 "No Content";
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

  if(req.url ~ "^/ingest/(.*?)/\?.*"){
    # Data Collection

    # If a visitor accepted Cookies...
    if(subfield(req.url.qs, "cookie", "&") == "1"){

      # Define Ingestly ID
      if(req.http.Cookie:ingestlyId){
        set var.ingestly_id = req.http.Cookie:ingestlyId;
      }else{
        set var.ingestly_id = subfield(req.url.qs, "rootId", "&");
      }

      # Define Session ID
      if(req.http.Cookie:ingestlySes){
        set var.session_id = req.http.Cookie:ingestlySes;
      }else{
        set var.session_id = subfield(req.url.qs, "rootId", "&");
      }

      # Set headers
      set obj.http.Access-Control-Allow-Origin = "*";
      set obj.http.Cache-Control = "no-store";
      add obj.http.Set-Cookie = "ingestlyId=" + var.ingestly_id
                              + "; Max-Age=" + var.cookie_lifetime
                              + "; Domain=" + var.cookie_domain
                              + "; Path=/; SameSite=Lax; HttpOnly; Secure;";
      add obj.http.Set-Cookie = "ingestlySes=" + var.session_id
                              + "; Domain=" + var.cookie_domain
                              + "; Path=/; SameSite=Lax; HttpOnly; Secure;";
      
    }else{

      # Anonymous Mode
      set var.ingestly_id = "anonymous";

    }

    return (deliver);

  }elseif(req.url ~ "^/consent/(.*?)/\?.*"){
    # Consent Management

    # Cookie Opt-out
    if(subfield(req.url.qs, "i", "&") == "0"){
      add obj.http.Set-Cookie = "ingestlyId=";
      add obj.http.Set-Cookie = "ingestlySes=";
      add obj.http.Set-Cookie = "ingestlyOptout=1"
                              + "; Max-Age=" + var.cookie_lifetime
                              + "; Domain=" + var.cookie_domain
                              + "; Path=/; SameSite=Lax; Secure;";
    }

    # Save Consent Information
    if(subfield(req.url.qs, "p", "&")){
      add obj.http.Set-Cookie = "ingestlyConsent=" + subfield(req.url.qs, "p", "&")
                              + "; Max-Age=" + var.cookie_lifetime
                              + "; Domain=" + var.cookie_domain
                              + "; Path=/; SameSite=Lax; Secure;";
    }

    set obj.http.Access-Control-Allow-Origin = "*";
    set obj.http.Cache-Control = "no-store";

    return (deliver);
  }
}
