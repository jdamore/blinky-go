require 'rufus/scheduler'

require './parser.rb'
require './light.rb'

def start id, go_url, pname
   update id, go_url, pname
end

private

$status = ""
def update id, go_url, pname
  new_status = pipeline_status(go_url, pname)
  puts "Will update status of build #{pname} from #{$status} to #{new_status}"
  light(id).send new_status
  $status = new_status
end


