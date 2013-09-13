require 'sinatra/activerecord/rake'
require File.dirname(__FILE__) + '/app'

# Migrate the DB
Rake::Task['db:migrate'].invoke

#run Vinz
run Rack::URLMap.new("/" => VinzWeb.new, 
                     "/api" => VinzAPI.new)
