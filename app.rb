require 'json'
require "sinatra"
require 'active_support/all'
require "active_support/core_ext"
require 'sinatra/activerecord'
require 'rake'
require 'twilio-ruby'

require 'open-uri'
require 'nokogiri'

require 'whenever'

set :environment, :development
# Load environment variables using Dotenv. If a .env file exists, it will
# set environment variables from that file (useful for dev environments)
configure :development do
  require 'dotenv'
  Dotenv.load
end

require_relative './models/image'
require_relative './models/swatch'

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
  
  #message = decide_response( body )
  message = "I didn't get that. " + help
  
  if body == "hi"
    message = get_greeting
  end

  # how do i make this time based? rather than the user asking for it??
  if body == "color"
    message = color_of_the_day
  end
  
  #should actually be any form of CONFIRMATIONS
  #which YES or NO is it? context aware use sessions to do this?
  if body == "yes"
    message = show_images
  end
  
  if body == "no"
    message = no_images 
  end

  if body == "help"
    message = help
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


#This might be a good idea to have!!!!!!!!!

# def decide_response blob
  
#   #return "I didn't understand"
  
#   if blob == "skills"
#     "My skills are  x , y , z "
#   elsif blob == "availability"  
#     "I'm available for hire now"
#   elsif blob == "something else "  
#     "Something else"
#   else
#     return "I didn't understand"
#   end 
  
# end 


CONFIRMATIONS = ["Yes","Yup","Totally","Totes","👍"]

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
  get_greeting + ", I\'m Jasper, your little color 🎨 helper! " + get_commands
end

# def get_help_message
#   "You're stuck, eh? " + get_commands
# end

def help
  "I\'m pretty helpful at finding images for the color of the day and giving you the color of the day just type \"colorize\" to get today’s color and “history” to pull up colors from this past week :woot: :woot:"
end


# def color_of_the_day
#   #JSON.load(s.themetic_words)
#   "Pantone's color of the day is Canton (16-5112) #6CA3A1, which stands for \'Powerful, Dynamic & Introspective\' " + "swatchPlaceHolder.png" + "Want images using canton?"
# end

def color_of_the_day
  #JSON.load(s.themetic_words)
  "Pantone's color of the day is Canton (16-5112) #6CA3A1, which stands for \'Powerful, Dynamic & Introspective\' " + "swatchPlaceHolder.png" + "Want images using canton?"
end

def show_images
  #create more than 1 greeting
  ["Awesome Sauce! Give me a second.","#winning, one sec","Next stop inspiration 🚂"].sample + "inspo1.jpeg" + "inspo2.jpeg"
end

def no_images
  "👋 Sounds good. Let me know if you would like images later on I’ll be happy to provide them. Happy Coloring! Ever need me, just type “Help” or “Colorize” and I’ll be waiting."
end 

def history
  #pull up the last seven entries from db
end

def error
  "Sorry I don't understand what you mean, type \"help\" for help."
  
end

# def error_response
#   error_prompt = ["I didn't catch that.", "Hmmm I don't know that word.", "What did you say to me? "].sample
#   error_prompt + " " + get_commands
# end
