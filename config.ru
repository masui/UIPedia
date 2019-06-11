require 'sinatra'
  
require './uipedia.rb'

Encoding.default_external = 'utf-8'

run Sinatra::Application
