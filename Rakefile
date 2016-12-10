# require your app file first
require './app'
require 'sinatra/activerecord/rake'

desc "This task is called by the Heroku scheduler add-on"
task :scrape_pantone do

  	Swatch.load_pantone

end
