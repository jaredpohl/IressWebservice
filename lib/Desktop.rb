require 'win32ole'

#IRESS DESKTOP APPLICATION METHODS TO ENTER PASSWORD IF USING THE WINDOWS DESKTOP WEBSERVICES
module Desktop
	def setupDesktop ()
		@wsh = WIN32OLE.new('Wscript.Shell')
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