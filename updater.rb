require 'rufus/scheduler'

require './parser.rb'
require './light.rb'

def start id, go_url, pname
  scheduler = Rufus::Scheduler.start_new
     scheduler.every '3s' do
    update id, go_url, pname
  end
  scheduler.join
end

private

$status = ""
def update id, go_url, pname
  pipeline = pipeline_details go_url, pname  
  new_status = light_status pipeline.last_build_status, pipeline.current_activity
  puts " Pipeline was last #{pipeline.last_build_status} and is currently #{pipeline.current_activity} 
 => Will update light status from #{$status} to #{new_status}"
  light(id).send new_status
  $status = new_status
end


def light_status pipeline_last_status, pipeline_activity
  return "building!" if pipeline_activity=="Building"
  return "failure!" if pipeline_last_status=="Failure"
  "success!"
end


