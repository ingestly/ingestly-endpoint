sub vcl_recv {
#FASTLY recv
  
  # Ingestly Main
  if(req.url ~ "^/ingestly-ingest/(.*?)/\?.*" || req.url ~ "^/ingestly-consent/(.*?)/\?.*" || req.url ~ "^/ingestly-bulk/(.*?)/\?.*"){
    if(table.lookup(ingestly_apikeys, subfield(req.url.qs, "key", "&")) == "true"){
      # Valid Ingestion
      error 204 "No Content";
    }else{
      # Invalid API Key
      error 401 "Unauthorized";
    }
  }

  # Ingestly PCM & Attribution Reporting
  if(req.url ~ "^/\.well-known/(attribution-reporting|private-click-measurement)/.*"){
    # Report Endpoint
    error 200 "OK";
  }
  if(req.url ~ "^/ingestly-pixel/.*?/\?.*"){
    # Pixel Redirector
    error 302 "Found";
  }

}

sub vcl_error {
#FASTLY error
  
  declare local var.ingestly_use_cookie STRING;
  declare local var.ingestly_cookie_domain STRING;
  declare local var.ingestly_cookie_lifetime STRING;
  declare local var.ingestly_id STRING;
  declare local var.ingestly_session_id STRING;

  set var.ingestly_use_cookie = table.lookup(ingestly_metadata, "use_cookie");
  set var.ingestly_cookie_domain = table.lookup(ingestly_metadata, "cookie_domain");
  set var.ingestly_cookie_lifetime = table.lookup(ingestly_metadata, "cookie_lifetime");

  # Data Collection
  if(req.url ~ "^/ingestly-ingest/(.*?)/\?.*" || req.url ~ "^/ingestly-bulk/(.*?)/\?.*"){
    
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
        if(var.ingestly_use_cookie == "true"){
          add obj.http.Set-Cookie = "ingestlyId=" + var.ingestly_id
                                  + "; Max-Age=" + var.ingestly_cookie_lifetime
                                  + "; Path=/; SameSite=Lax; HttpOnly; Secure;";
        }
      }

      if(req.url ~ "^/ingestly-ingest/(.*?)/\?.*"){
        # Define Session ID
        if(req.http.Cookie:ingestlySes){
          set var.ingestly_session_id = req.http.Cookie:ingestlySes;
        }else{
          set var.ingestly_session_id = subfield(req.url.qs, "rootId", "&");
        }
        if(var.ingestly_use_cookie == "true"){
          add obj.http.Set-Cookie = "ingestlySes=" + var.ingestly_session_id
                                  + "; Path=/; SameSite=Lax; HttpOnly; Secure;";
        }
      }

    }
    return (deliver);
    
  }

  # Consent Management
  if(req.url ~ "^/ingestly-consent/(.*?)/\?.*"){
   
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
                              + "; Max-Age=" + var.ingestly_cookie_lifetime
                              + "; Domain=" + var.ingestly_cookie_domain
                              + "; Path=/; SameSite=Lax; Secure;";
    }
    return (deliver);
  }

  # Private Click Measurement (Redirector)
  if(req.url ~ "^/ingestly-pixel/pcm/\?.*"){  
    set obj.http.Access-Control-Allow-Origin = "*";
    set obj.http.Cache-Control = "no-store";
    set obj.http.Location = "https://" + req.http.host + "/.well-known/private-click-measurement/trigger-attribution/"
                          + subfield(req.url.qs, "trigger_data", "&") + "/" + subfield(req.url.qs, "trigger_priority", "&");
    return (deliver);
  }

  # Attribution Reporting & Private Click Measurement (Common)
  if(req.url ~ "^/\.well-known/(attribution-reporting|private-click-measurement)/.*"){
    set obj.http.Access-Control-Allow-Origin = "*";
    set obj.http.Cache-Control = "no-store";
    return (deliver);
  }
}

