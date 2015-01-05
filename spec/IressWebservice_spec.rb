require 'yaml'
require 'spec_helper'
require 'Date'
require 'active_support/core_ext'

describe IressWebservice do	
	CONFIG = YAML.load_file("config.yml") unless defined? CONFIG
	
	before :all do
		@iress = IressWebservice.new(CONFIG['user_name'], CONFIG['company_name'], CONFIG['password'], CONFIG['server'], CONFIG['ios_master_password'])
	end

	#define random stocks and portfolios?!?
	#define random log ins and passwords!?!
	#define random group codes 

	#TEST OBJECT INITIALISATION

	it "should start a new IressWebservice instance" do
		@iress.should be_an_instance_of IressWebservice
	end

	#TEST IRESS CONNECTIONS

	it "should have a variable named @ips which is a Savon::Client object" do
		@iress.ips.should be_an_instance_of Savon::Client 		
	end

	it "should be able to start an iress session and return a result" do
		#do we want to have more details as to the kind of hash, ie its form etc?
		@iress.iress_session_start.should be_kind_of Hash
	end

	it "should provide an array of supported operations from the web service" do
		@iress.iress_operations?.should be_kind_of Array
	end

	#TEST IRESS METHODS
	it "The security_time_series method returns an array" do
		#need to put in the different ticker and frequencies
		@iress.security_time_series("BHP", "daily", Date.today.months_ago(1).end_of_month, Date.today).should be_kind_of Array
	end

	# test the way the methods work
	# step 1, form the xml_request by passing variables in
	# step 2, make a call on the web service
	# step 3, check that the response is well formed
	
	#TEST IPS CONNECTIONS

	it "should have a variable named @iress which is a Savon::Client object" do
		@iress.iress.should be_an_instance_of Savon::Client 		
	end

	it "should be able to start an ips session and return a result" do
		#do we want to have more details as to the kind of hash, ie its form etc?
		@iress.ips_session_start.should be_kind_of Hash
	end

	it "should provide an array of supported operations from the web service" do
		@iress.ips_operations?.should be_kind_of Array
	end

	it "should return an array of portfolios" do
		@iress.accounts_in_group("IMA_AUST").should be_kind_of Array
	end

	it "account market value should return a numeric" do
		@iress.account_market_value("HIPHAMLAE", Date.today).should be_kind_of Numeric
	end

	it "account market value should return a numeric" do
		@iress.account_market_value("HIPHAMLAE", Date.today).should be_kind_of Numeric
	end

	it "sum account cash transactions return a value" do
		@iress.sum_acct_cash_transactions("HIPHAMLAE", Date.today.months_ago(3).end_of_month, Date.today).should be_kind_of Numeric
	end

	it "ips get position should return an array" do
		@iress.ips_get_position(Date.today, "HIPHAMLAE").should be_kind_of Array
	end

end

