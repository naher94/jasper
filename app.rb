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

client = Twilio::REST::Client.new ENV["TWILIO_ACCOUNT_SID"], ENV["TWILIO_AUTH_TOKEN"]

# Hook this up to your Webhook for SMS/MMS through the console

#get '/incoming_sms/:id' do

# http://localhost/incoming_sms?query=Something&From=234234234

get '/incoming_sms' do
  
  session["last_context"] ||= nil
  sender = params[:From] || ""
  body = params[:Body] || ""
  
  #"Hello" -> "hello"
  #"Hllo  helo " -> "hllo helo " -> "hllo helo"
  #"HELLO" -> "hello"
  body = body.downcase.strip
  
  message = decide_response( body )
  
  if body == "hi"
    message = get_greeting
  end
  
  
  
      
  twiml = Twilio::TwiML::Response.new do |resp|
    resp.Message message
  end
    
  return twiml.text
end

# ----------------------------------------------------------------------
#   METHODS
#   Add any custom methods below
# ----------------------------------------------------------------------

private 


#what does this do??

def decide_response blob
  
  #return "I didn't understand"
  
  if blob == "skills"
    "My skills are  x , y , z "
  elsif blob == "availability"  
    "I'm available for hire now"
  elsif blob == "something else "  
    "Something else"
  else
    return "I didn't understand"
  end 
  
end 




GREETINGS = ["Hi","Yo", "Hey","Howdy", "Hello", "Ahoy", "‘Ello", "Aloha", "Hola", "Bonjour", "Hallo", "Ciao", "Konnichiwa"]

COMMANDS = "hi, who, what, where, when, why and play."

def get_commands
  error_prompt = ["I know how to: ", "You can say: ", "Try asking: "].sample
  
  return error_prompt + COMMANDS
end

def get_greeting
  return GREETINGS.sample
end

def get_about_message
  get_greeting + ", I\'m SMSBot 🤖. " + get_commands
end

def get_help_message
  "You're stuck, eh? " + get_commands
end

def error_response
  error_prompt = ["I didn't catch that.", "Hmmm I don't know that word.", "What did you say to me? "].sample
  error_prompt + " " + get_commands
end

