require 'nokogiri'
require 'curb'
require 'open-uri'
require './pipeline.rb'


def pipeline_details go_url, pname
  pipeline = Pipeline.new
  pipeline.name = pname
  pipeline.last_build_status = combined_status pipeline_jobs_statuses go_url, pname
  pipeline.current_activity = combined_activity pipeline_jobs_activity go_url, pname
  pipeline
end

private

def pipeline_jobs_statuses go_url, pname
  xml("http://#{go_url}/go/cctray.xml")
     .xpath("//Projects").xpath("//Project")
     .select { |project| project.attribute("name").value().include?(pname) }
     .map { |project| project.attribute("lastBuildStatus").value() }
end

def pipeline_jobs_activity go_url, pname
  xml("http://#{go_url}/go/cctray.xml")
      .xpath("//Projects").xpath("//Project")
      .select { |project| project.attribute("name").value().include?(pname) }
      .map { |project| project.attribute("activity").value() }
end

def xml url
  # Nokogiri.parse Curl.get(url).body_str 
  Nokogiri::XML(open(url))
end

def combined_status statuses
  return "Failure" if statuses.include?("Failure")
  "Success"
end

def combined_activity activities
  return "Building" if activities.include?("Building")
  "Sleeping"
end