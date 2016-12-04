# require your app file first
require './app'
require 'sinatra/activerecord/rake'


desc "This task is called by the Heroku scheduler add-on"
task :send_trending_giphy do

  Giphy::Configuration.configure do |config|
    config.api_key = ENV["GIPHY_API_KEY"]
  end
  
  results = Giphy.trending(limit: 5)
  client = Twilio::REST::Client.new ENV["TWILIO_ACCOUNT_SID"], ENV["TWILIO_AUTH_TOKEN"]

  unless results.empty? 
    
    #puts results.to_yaml
    gif = results.sample.original_image.url
    puts gif
    
    client.account.messages.create(
      :from => ENV["TWILIO_FROM"],
      :to => "+14803308165",
      :body => "Here's a little something to brighten your day. A trending gif from Giphy.",
      :media_url => gif
    )
  end 

end

task :send_daily_update do

  ActiveRecord::Base.connection
  client = Twilio::REST::Client.new ENV["TWILIO_ACCOUNT_SID"], ENV["TWILIO_AUTH_TOKEN"]

  User.all.each do |u|
    
    message = "Daily update: \n"
    u.tracks.each do |t|
      stock = StockQuote::Stock.quote( t.symbol )
      message += "#{stock.name} (#{stock.symbol}) is at #{stock.ask}. Change: #{stock.change_percent_change}. \n"
    end
    
    client.account.messages.create(
      :from => ENV["TWILIO_FROM"],
      :to => u.phone_number,
      :body => message
    )
    
  end

end
