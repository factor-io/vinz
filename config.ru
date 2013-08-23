require File.dirname(__FILE__) + '/app'

#run Vinz
run Rack::URLMap.new("/" => VinzApp.new, 
                     "/api" => VinzAPI.new)
