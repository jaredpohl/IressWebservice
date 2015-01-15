#reconcile.rb
require 'rubygems'
require_relative 'IressWebservice.rb'
require 'Date'
require 'CSV'
require 'active_support/core_ext'

CONFIG = YAML.load_file("config.yml") unless defined? CONFIG
CONFIG['to_date'] = Date.today

#p CONFIG 
#GET CUSTODIAN DATA
#cash
#securities

#start iress ws sessions
iress = IressWebservice.new(CONFIG['user_name'], CONFIG['company_name'], CONFIG['password'], CONFIG['server'], CONFIG['ios_master_password'])
#puts "open Iress" unless iress.is_iress_open?
iress.iress_session_start 
iress.ips_session_start
puts iress.get_pricing_quote (["BHP","SEK"])
puts iress.get_security_info(["BHP","SEK"])