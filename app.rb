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
  image_url = nil
  images = []
  
  if GREETINGS.include? body
    message = get_greeting
    image_url = "http://rehanbutt.com/img/colorBot/jasper.png"
  end

  # how do i make this time based? rather than the user asking for it??
  if body == "color"
    message = color_of_the_day
  end

  if body.include? "images"
    message = show_images_message
    #image_url = get_image_url
    images = show_images_image
  end

  if body.include? "who"
    message = get_about_message
  end
  
  if body == "no"
    message = no_images 
  end

  if body.include? "help"
    message = help
  end

  if body.include? "colorize"
    message = color_of_the_day
  end

  if body.include? "thanks"
    message = your_welcome
  end

  if body.include? "more"
    message = show_images_message #push the message first?
    images = more_images
  end

  if body.include? "yesterday"
    message = yesterday_color_text
    images = yesterday_color_images
  end

  # image_url = nil 
  # image_url = "http://rehansapp.heroku.com/path/to/image.jpg"
      
  twiml = Twilio::TwiML::Response.new do |resp|
    resp.Message do |m|
        m.Body message
        unless image_url.nil?
            m.Media image_url
        end
        unless images.empty?
          images.each do |image|
            m.Media image.image
          end
        end
    end

  end
    
  return twiml.text
end

# ----------------------------------------------------------------------
#   METHODS
#   Add any custom methods below
# ----------------------------------------------------------------------

private

CONFIRMATIONS = ["Yes","Yup","Totally","Totes","👍"]

GREETINGS = ["hi","yo", "hey","howdy", "hello", "ahoy", "ello", "aloha", "hola", "bonjour", "hallo", "ciao", "konnichiwa"]

COMMANDS = "hi, who, what, where, when, why and play."

TITLES = ["master", "sensei", "ninja", "wrangler", "doctor", "guru", "wizard", "professional"]

def get_commands
  error_prompt = ["I know how to: ", "You can say: ", "Try asking: "].sample
  
  return error_prompt + COMMANDS
end

def get_greeting
  return GREETINGS.sample + " I'm Jasper your friendly neighborhood color " + TITLES.sample + " 🎨, pleased to meet you!" + " Want to be colorized? just say \'colorize\' Not sure what that means, no worries just give it a shot its pretty fun 😆"
end

def get_about_message
  GREETINGS.sample + ", I\'m Jasper, your little color 🎨 helper! To help expand your color vocabulary and provide a new form of inspiration"
end

# def get_help_message
#   "You're stuck, eh? " + get_commands
# end

def help
  "I\'m pretty helpful at finding images for the color of the day and giving you the color of the day just type \"colorize\" to get today’s color and \"images\" to pull up images that use today's color 🎉"
end

def color_of_the_day #colorize

  colorToday = Swatch.where( "DATE(date) = ?", Date.today).first
  #show an image of the color swatch
  words = JSON.load(colorToday.themetic_words)
  "Today's color is #{colorToday.name} #{colorToday.pantone} #{colorToday.hex}, which stands for #{words[0].downcase}, #{words[1].downcase}, #{words[2].downcase}"
  # "Pantone's color of the day is Canton (16-5112) #6CA3A1, which stands for \'Powerful, Dynamic & Introspective\' " + "swatchPlaceHolder.png" + "Want images using canton?"
end

def show_images_message
  #create more than 1 greeting
  ["Awesome Sauce! Give me a second.","#winning, one sec","Next stop inspiration! 🚂"].sample
end

def show_images_image
    #replace with images from the images table of that correct date    
    Image.where( "DATE(date) = ?", Date.today).first(2)
end

def your_welcome
    return ["Your welcome", "Of course", "For sure", "You are very welcome"].sample + " Happy coloring! 🎨🎉"#" let me know if you need any other color inspiration. I'll be here!"
end

def no_images
  "👋 Sounds good. Let me know if you would like images later on I’ll be happy to provide them. Happy Coloring! Ever need me, just type \"Help\" or \"Colorize\" and I’ll be waiting."
end 

def more_images
  Image.where( "DATE(date) = ?", Date.today).last(2)
end

def yesterday_color_text
  colorYesterday = Swatch.where( "DATE(date) = ?", Date.today.prev_day).first
  words = JSON.load(colorYesterday.themetic_words)
  "Yesterday's color was #{colorYesterday.name} #{colorYesterday.pantone} #{colorYesterday.hex}, which stands for #{words[0].downcase}, #{words[1].downcase}, #{words[2].downcase}"

end

def yesterday_color_images
  Image.where( "DATE(date) = ?", Date.today.prev_day).last(2)
end
# def history
#   #pull up the last seven entries from db
#   "History Command"
# end

def error
  error_prompt = ["I didn't catch that.", "Hmmm I don't know that word.", "What did you say to me?", "Sorry I don't understand what you mean."].sample
  return error_prompt + " " + help
  
end

# def error_response
#   error_prompt = ["I didn't catch that.", "Hmmm I don't know that word.", "What did you say to me? "].sample
#   error_prompt + " " + get_commands
# end
