module PathConfig
  PIN_2010_PATH = File.join(File.dirname(File.expand_path(__FILE__)),"../../")

  UNICORN_SH_PATH = File.join(PIN_2010_PATH,"sh")
  WORKER_SH_PATH = File.join(PIN_2010_PATH,"sh/worker_sh")
  SERVERS_SH_PATH = File.join(PIN_2010_PATH,"sh/service_sh")

  REDIS_SERVICE_SH = File.join(SERVERS_SH_PATH,"redis_service.sh")
  FEED_LUCENE_SH = File.join(SERVERS_SH_PATH,"feeds_lucene_service.sh")
  MINDMAP_LUCENE_SH = File.join(SERVERS_SH_PATH,"mindmaps_lucene_service.sh")
  RESQUE_WEB_SH = File.join(SERVERS_SH_PATH,"resque_web_service.sh")


  MEV6_QUEUES = [
    "mindmap_image_cache_resque_queue"
  ]
  
  QUEUES = MEV6_QUEUES 
end
