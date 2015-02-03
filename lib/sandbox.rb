#reconcile.rb
require 'rubygems'
#require 'savon'
require_relative 'IressWebservice'
require 'Date'
require 'CSV'

CONFIG = YAML.load_file("config.yml") unless defined? CONFIG
CONFIG['to_date'] = Date.today

#start iress ws sessions
iress = IressWebservice.new(CONFIG['user_name'], CONFIG['company_name'], CONFIG['password'], CONFIG['server'])
puts iress.debug
iress.debug= true
puts iress.debug

iress.iress_session_start
iress.ips_session_start

iress.ips_operations

puts iress.get_pricing_quote(["BHP","SEK"])


