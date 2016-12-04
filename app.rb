require 'json'
require "sinatra"
require 'active_support/all'
require "active_support/core_ext"
require 'sinatra/activerecord'
require 'rake'

require 'twilio-ruby'

# Load environment variables using Dotenv. If a .env file exists, it will
# set environment variables from that file (useful for dev environments)
configure :development do
  require 'dotenv'
  Dotenv.load
end


# enable sessions for this project

enable :sessions

# First you'll need to visit Twillio and create an account 
# you'll need to know 
# 1) your phone number 
# 2) your Account SID (on the console home page)
# 3) your Account Auth Token (on the console home page)
# then add these to the .env file 
# and use 
#   heroku config:set TWILIO_ACCOUNT_SID=XXXXX 
# for each environment variable

# CREATE A CLient
client = Twilio::REST::Client.new ENV["TWILIO_ACCOUNT_SID"], ENV["TWILIO_AUTH_TOKEN"]


# Use this method to check if your ENV file is set up

get "/from" do
  #401
  ENV["TWILIO_FROM"]
end

# Test sending an SMS
# change the to to your number 

get "/send_sms/" do 

  client.account.messages.create(
    :from => ENV["TWILIO_FROM"],
    :to => "+1XXXXXXXXXXXX",
    :body => "Hey there. This is a test"
  )
  "Sent message"
  
end

# Hook this up to your Webhook for SMS/MMS through the console

get '/incoming_sms' do

  session["counter"] ||= 0
  count = session["counter"]
  
  sender = params[:From] || ""
  body = params[:Body] || ""
  query = body.downcase.strip

  if session["counter"] < 1
    message = "Thanks for your first message. From #{sender} saying #{body}"
  else
    message = "Thanks for message number #{ count }. From #{sender} saying #{body}"
  end
  
  session["counter"] += 1
  
  twiml = Twilio::TwiML::Response.new do |r|
    r.Message message
  end
  twiml.text

end





error 401 do 
  "Not allowed!!!"
end

