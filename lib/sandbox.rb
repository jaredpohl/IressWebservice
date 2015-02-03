#reconcile.rb
#require 'rubygems'
require 'savon'
require_relative 'IressWebservice'
require 'Date'
require 'CSV'

CONFIG = YAML.load_file("config.yml") unless defined? CONFIG
CONFIG['to_date'] = Date.today

#start iress ws sessions
#iress = IressWebservice.new(CONFIG['user_name'], CONFIG['company_name'], CONFIG['password'], CONFIG['server'])
#puts iress.debug
#iress.debug= true
#puts iress.debug

client = Savon.client(
	wsdl: 'https://betawebservices.iress.com.au/v4/wsdl.aspx', 
	namespace: "http://betawebservices.iress.com.au/v4/", 
	namespace_identifier: :v4, 
	env_namespace: :soapenv, 
	convert_request_keys_to: :camelcase,	
	log: false)

puts client.operations

#puts iress.get_pricing_quote(["BHP","SEK"])


