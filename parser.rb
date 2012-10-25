require 'nokogiri'
require 'curb'


def pipeline_status go_url, pname
  pid = pipeline_id(go_url, pname)
  statuses = Array.new
  stage_feeds("http://#{go_url}/go/api/pipelines/#{pname}/#{pid}.xml").each do |stage_feed|
    statuses << stage_status(stage_feed)
  end
  combined_status statuses
end


private

def xml url
  Nokogiri.parse(Curl.get(url))
end


def pipeline_id go_url, pname  
  xml("http://#{go_url}/go/api/pipelines/#{pname}/stages.xml")
    .xpath("//feed")
    .xpath("//entry")
    .xpath("//id")
    .collect { |e| e.content().to_s }[1]
    .split(pname)[1].split('/')[1]  
end


def stage_feeds pipeline_feed
  stage_feeds = xml(pipeline_feed)
      .xpath("//pipeline")
      .xpath("//stages")
      .xpath("//stage")
      .collect { |e| e.attribute("href").to_s }
end

def stage_status stage_feed
  xml(stage_feed)
    .xpath("//stage")
    .xpath("//result")[0]
    .content
end

def combined_status statuses
  puts statuses
  return "building!" if statuses.include?("Unknown")
  return "failure!" if statuses.include?("Failed")
  "success!"
end

def xml url
  Nokogiri.parse Curl.get(url).body_str 
end