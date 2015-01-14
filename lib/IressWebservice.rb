require 'Savon'
require 'win32ole'

#IRESS DESKTOP APPLICATION METHODS TO ENTER PASSWORD IF USING THE WINDOWS DESKTOP WEBSERVICES
module Desktop
	def setupDesktop (wsh)
		@wsh = wsh
	end

	def is_iress_open?
		if @wsh.AppActivate('IRESS')
			return true
		else
			return false
		end
	end

	def open_iress
		#open Iress
		system("start Iress.exe")
		sleep(5)
	end

	def enter_iress_login_details
		if @wsh.AppActivate('Login Details')
			sleep(2)
			#log in
			key_string = "#{@user_name}{TAB}"
			@wsh.SendKeys(key_string)
			#organisation code
			key_string = "#{@company_name}{TAB}"
			@wsh.SendKeys(key_string)
			#password
			key_string = "#{@password}{TAB}"
			@wsh.SendKeys(key_string)
			#enter
			@wsh.SendKeys("{ENTER}")
			sleep(5)
			return true
		else
			puts "IressWebservice: cannot locate 'Login Details' window."
			return false
		end
	end

	def enter_iress_master_pass
		# Create an instance of the Wscript Shell:
		if @wsh.AppActivate('IOS Master Login') 
		  sleep(2) 
		  #enter master password  
		  key_string = "#{@master_password}{ENTER}" 
		  @wsh.SendKeys(key_string)
		  sleep(5)
		  return true
		else
			puts "IressWebservice: cannot locate 'IOS Master Login' window."
			return false
		end
	end

	def close_iress
		#if shell can make iress visible
		if @wsh.AppActivate('IRESS')
			#CLOSE APPLICATION
			@wsh.SendKeys('%{F4}')
			sleep(2)
			#CONFIRM CLOSE
			@wsh.SendKeys('{ENTER}')
			return true
		else
			puts "IressWebservice: cannot close iress."
			return false
		end	
	end
end

#IRESS WEB SERVICES WRAPPER

class IressWebservice

	#set getters and setters
	attr_reader :iress_session_key, :ips_session_key, :iress_wsdl, :ips_wsdl, :ips, :iress 
	attr_writer :iress_session_key, :ips_session_key, :iress_wsdl, :ips_wsdl, :server 
	
	#mixin the desktop module
	include Desktop

	def initialize(user_name, company_name, password, server, master_password)
	 	#set instance variables
	 	@user_name = user_name
	 	@company_name = company_name
	 	@password = password #iress password
	 	@master_password = master_password #ios master password
	 	@server = server
	 	@iress_session_key = ""
	 	@ips_session_key = ""
	 	@iress_wsdl = "http://127.0.0.1:51234/wsdl.aspx?un=#{@user_name}&cp=#{@company_name}&svc=IRESS&svr=&pw=#{@password}"
	 	@ips_wsdl = "http://127.0.0.1:51234/wsdl.aspx?un=#{@user_name}&cp=#{@company_name}&svc=IPS&svr=#{@server}&pw=#{@password}"
	  #wasnt sure whether to make two different classes here, one for Iress one for IPS.. perhaps next iteration.
	  
	  #web service objects
	  @iress = Savon.client(wsdl: @iress_wsdl, endpoint: "http://127.0.0.1:51234/soap.aspx", namespace: "http://webservices.iress.com.au/v4/", namespace_identifier: :v4, env_namespace: :soapenv, convert_request_keys_to: :camelcase,	log: false)
	  @ips = Savon.client(wsdl: @ips_wsdl, endpoint: "http://127.0.0.1:51234/soap.aspx", namespace: "http://webservices.iress.com.au/v4/", namespace_identifier: :v4, env_namespace: :soapenv, convert_request_keys_to: :camelcase,	log: false)
		
		#set up the connection to the desktop webservice.. maybe push into the apps that use this library if need
		setupDesktop(WIN32OLE.new('Wscript.Shell'))
	end

	
	#IRESS WEBSERVICE METHODS
	def form_iress_xml_request(session_key="",param_hash)
		iress_hash = {
			Input: {
			  Header:{
			  	SessionKey: session_key,
			  	RequestID: "",
			  	Updates: "false",
			  	Timeout: 25,
			  	PageSize: 1000,
			  	WaitForResponse: true,
			  	PagingBookmark: "",
			  	PagingDirection: 0
			  },
			  Parameters:{ }
			}
		}
		iress_hash[:Input][:Parameters] = param_hash
		return iress_hash
	end
	
	def iress_session_start
		#Starts the iress web service session by invoking iress_session_start and returns the Savon Object
		response = @iress.call(:iress_session_start, message: form_iress_xml_request({UserName: @user_name, CompanyName: @company_name, Password: @password, ApplicationID: "",ApplicationLabel: "",PreviousSessionKey: "",SessionTimeout: "",AuthenticationType: "",SessionNumberToKick: "",KickLikeSessions: ""})) 
		#set the session key in the object
		@iress_session_key = response.to_hash[:iress_session_start_response][:output][:result][:data_rows][:data_row][:iress_session_key]
		#return the result from the query
		return response.body[:iress_session_start_response][:output][:result]
	end

	def get_security_info (ticker)
		#TAKES AN ARRAY OF TICKERS AND PASSES BACK THEIR SECURITY INFORMATION.
			response = @iress.call(:security_information_get, message: form_iress_xml_request(@iress_session_key, {SecurityCode: ticker , Exchange: nil} ))
			return response.body[:security_information_get_response][:output][:result]
	end

	def get_pricing_quote (ticker)
		#TAKES AN ARRAY OF TICKERS AND PASSES BACK THEIR PRICE INFORMATION.
			response = @iress.call(:pricing_quote_get, message: form_iress_xml_request(@iress_session_key, {SecurityCode: ticker , Exchange: nil, DataSource:nil} ))
			return response.body[:pricing_quote_get_response][:output][:result]
	end

	def security_time_series(security_code, request_frequency, from_date, to_date)
		#calls the time_series_get method

		#request_frequency : "daily", "monthly", "yearly"
		param_hash = {SecurityCode: security_code, Exchange: nil, DataSource: nil, Frequency: request_frequency, TimeSeriesFromDate: from_date, TimeSeriesToDate: to_date}
		#
		response = @iress.call(:time_series_get, message: form_iress_xml_request(@iress_session_key, param_hash))
		
		#returns back an array of hashes based on the iress_time_series_get method. Keys are OpenPrice HighPrice LowPrice ClosePrice TotalVolume TotalValue TradeCount AdjustmentFactor TimeSeriesDate
		return response.body[:time_series_get_response][:output][:result][:data_rows][:data_row]
	end

	#IPS WEBSERVICE METHODS
	def form_ips_xml_request(session_key="",param_hash)
		ips_hash = {
			Input: {
			  Header:{
			  	ServiceSessionKey: session_key,
			  	RequestID: "",
			  	Updates: "false",
			  	Timeout: 25,
			  	PageSize: 1000,
			  	WaitForResponse: true,
			  	PagingBookmark: "",
			  	PagingDirection: 0
			  },
			  Parameters:{ }
			} 
		}
		ips_hash[:Input][:Parameters] = param_hash
		return ips_hash
	end

	def ips_session_start

		#Invoke ServiceSessionStart on ips service and return session key
		response = @ips.call(:service_session_start, message: form_ips_xml_request({IRESSSessionKey: @iress_session_key, Service: "IPS", Server: @server})) 
		#set the session key 
		@ips_session_key = response.body[:service_session_start_response][:output][:result][:data_rows][:data_row][:service_session_key]
		#return the result of the soap request
		return response.body[:service_session_start_response][:output][:result]
	end

	def ips_operations?
		@ips.operations 
	end

	def iress_operations?
		@iress.operations
	end

	def accounts_in_group(group_code)
		#retrieve all the accounts in a group in Iress
		response = @ips.call(:ips_account_get_by_group2, message: form_ips_xml_request(@ips_session_key, {GroupCodeArray: { GroupCode: group_code}})) 
		
		#returns an array of hash data about the accounts in a group
		#if there is only one portfolio in a group, it just returns a hash, not an array of hashes, so push it into an array.
		result = response.body[:ips_account_get_by_group2_response][:output][:result][:data_rows][:data_row]
		if result.is_a?(Hash) 
			return_array = []
			return_array << result
			return return_array
		else
			return result
		end
	end

	def account_market_value(account_code, date)
		param_hash = {
			AccountCode: account_code, 
			FromDate: date, 
			ToDate: date,	
			Pricing: "Cum", 
			PortfolioCode: account_code,	
			Settled: 0,	
			Proposed: 0,
			Currency: "", 
			ShowHiddenPositions: 0, 
			HideExcludeFromReportPositions: 1, 
			HideExcludeFromFeePositions: 1, 
			HideUnmanagedPositions: 0
		}
		response = @ips.call(:ips_market_value_get_by_account1, message: form_ips_xml_request(@ips_session_key, param_hash))

		return response.body[:ips_market_value_get_by_account1_response][:output][:result][:data_rows][:data_row][:market_value].to_f

	end

	def ips_account_cash_transactions(account_code, from_date, to_date, security_code="CASH")		
		param_hash = {
			AccountCode: account_code, 
			DateFilterType: "SettleDate", 
			DateFrom: from_date, 
			DateTo: to_date, 
			SecurityHandle: "",	
			SecurityCode: security_code,	
			Exchange: "UNL",
			PortfolioCode: account_code,	
			Proposed: 0,
			ShowHiddenPositions: 0,	
			HideExcludeFromReportPositions: 1,	
			HideExcludeFromFeePositions: 0, 
			HideUnmanagedPositions: 0
		}

		response = @ips.call(:ips_transaction_ex_get_by_account1, message: form_ips_xml_request(@ips_session_key, param_hash)) 

		#returns an array of the cash transactions from webs service
		response.to_hash[:ips_transaction_ex_get_by_account1_response][:output][:result][:data_rows][:data_row]
	end

	def sum_acct_cash_transactions(account_code, from_date, to_date, security_code="CASH")

		transaction_array = ips_account_cash_transactions(account_code, from_date, to_date, security_code="CASH")
		#sums the cash transactions for an account returned from <>.  returns a total of cash transaction values.
		return 0.0 if transaction_array.nil? 
		#iress transaction types
		transaction_types = ["DJ", "AE", "RE", "DI", "FR", "RI", "RW", "AD", "MA", "RR"]
	
		if transaction_array.is_a? (Hash) then
			#if there is only one transaction, ie a hash is returned sum as follows:
			total_cash_flow = 0
			transaction_array.each do |row|
				#pp row
				total_cash_flow = total_cash_flow + row[1].to_f if row[0].to_s == "transaction_value"
			end
			return total_cash_flow
		else 
			#when there is an Array of Hashes then sum the cashflows as follows:
			total_cash_flow = 0
			transaction_array.each do |transaction|
				#puts "#{transaction[:security_code]}, #{transaction[:transaction_value]}, #{transaction[:transaction_type]}"
				#pp transaction
				total_cash_flow = total_cash_flow + transaction[:transaction_value].to_f if transaction_types.include? transaction[:transaction_type]
				#puts "#{transaction[:security_code]}, #{transaction[:transaction_value]},  #{transaction[:transaction_type]}, #{total_cash_flow}"
			end
			return total_cash_flow #.to_f
		end
	end

	def ips_get_portfolio_irr_request(account_code, from_date, to_date)
	  #if the date range is greater than 1 month, it breaks returns into monthly increments.
	  #returns an array of 1m returns with their corresponding benchmark returns and the as at date for both
	  param_hash = {
    	AccountCode: account_code,
    	DateFrom: from_date,
    	DateTo: to_date,
    	FeesAndTaxes: "AfterFeesAndTaxesNoImp",
    	PricingFrom: "Live",
    	PricingTo: "Live",
    	PortfolioCodeArray: {
    		PortfolioCode: account_code
    	},
    	Settled: 0,
    	ShowHiddenPositions: 0,
    	HideExcludeFromReportPositions: 0,
    	HideExcludeFromFeePositions: 0,
    	HideUnmanagedPositions: 0,
    	TWRRSummary: 0,
    	TWRRDaily: 1,
    	UseExposure: 1
    }

		result = @ips.call(:ips_profit_analysis_twrr_get_by_account1, message: form_ips_xml_request(@ips_session_key, param_hash))
		return result.body[:ips_profit_analysis_twrr_get_by_account1_response][:output][:result][:data_rows][:data_row]#[:account_twrr]
	end	

	def ips_get_portfolio_irr(account_code, from_date, to_date)
		#ips_get_portfolio_irrs will return a hash if the length of time is less
		if ips_get_portfolio_irr_request(account_code, from_date, to_date).is_a? Hash 
			return ips_get_portfolio_irr_request(account_code, from_date, to_date)[:account_twrr]
		else
			total_return = 0
			ips_get_portfolio_irr_request(account_code, from_date, to_date).each do |row|
				total_return = total_return + row[:account_twrr]
			end
			return total_return
		end
	end

	def ips_get_position(to_date, account_code)
		#set params
		param_hash = {AccountCode: account_code, Date: to_date, ShowFilter:0, PreviousClose: 0, HideClosedPositions: 1, Proposed: 0, ExcludeFromReportFilter: 1}
		#invoke soap request
		result = @ips.call(:ips_basic_position_get_by_account1, message: form_ips_xml_request(@ips_session_key,param_hash))
		#return position data
		return result.body[:ips_basic_position_get_by_account1_response][:output][:result][:data_rows][:data_row] 
	end
end

