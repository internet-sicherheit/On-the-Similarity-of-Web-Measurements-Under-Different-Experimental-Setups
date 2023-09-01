requests:

id:INTEGER,browser_id:STRING,site_id:INTEGER,subpage_id:INTEGER,visit_id:STRING,url:STRING,top_level_url:STRING,method:STRING,referrer:STRING,headers:STRING,is_XHR:INTEGER,is_third_party_channel:INTEGER,is_third_party_to_top_window:INTEGER,resource_type:STRING,time_stamp:DATETIME,is_websocket:INTEGER,body:STRING,etld:STRING,content_hash:STRING

cookies:

id:STRING,browser_id:STRING,site_id:INTEGER,visit_id:STRING,expiry:DATETIME,is_secure:INTEGER,is_http_only:INTEGER,same_site:STRING,name:STRING,value:STRING,host:STRING,path:STRING,time_stamp:DATETIME,is_host_only:INTEGER,is_session:INTEGER,is_third_party:INTEGER

responses:

id:INTEGER,browser_id:STRING,site_id:INTEGER,subpage_id:INTEGER,visit_id:INTEGER,url:STRING,time_stamp:DATETIME,response_status:STRING,response_status_text:STRING,content_hash:STRING,headers:STRING,body:STRING,etld:STRING

localstoragE:

id:STRING,browser_id:STRING,site_id:INTEGER,subpage_id:INTEGER,visit_id:STRING,host:STRING,key:STRING,value:STRING,time_stamp:DATETIME