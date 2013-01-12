<<<<<<< HEAD
# This file is used by Rack-based servers to start the application.

require ::File.expand_path('../config/environment',  __FILE__)
run Pizzaparty::Application
=======
require "rubygems"
require "bundler"

Bundler.require

require "./app"
run Sinatra::Application
>>>>>>> dd098e945e905c67ac3411dd395d6653982e7011
