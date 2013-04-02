#!/usr/bin/env ruby

# Class used to connect to yate's extmodule using sockets or pipes

require 'socket'
require 'fcntl'
include Socket::Constants

class Yate
	# @type String: Type of the event
	# @name String: Name of the message
	# @retval String: Return value of the message
	# @origin Number: Time the message was generated
	# @id String: Temporarily unique message ID
	# @handled Boolean: Was the message handled or not
	# @params Hash: Message parameters, $obj->params["name"]="value"
	attr_accessor :type, :name, :retval, :origin, :id, :handled, :params

	# Static function to output a string to Yate's stderr or logfile
	# @param str String to output
	def self.output(str)
		if ($yate_socket)
			_yate_print("%%>output:#{str}")
		else
			$yate_stderr.puts(str)
			$yate_stderr.flush
		end
	end

	# Static function to output a string to Yate's stderr or logfile
	#  only if debugging was enabled.
	# @param str String to output, or boolean (true/false) to set debugging
	def self.debug(str)
		if str === true
			$yate_debug = true
		elsif str === false
			$yate_debug = false
		elsif $yate_debug
			Yate::output(str)
		end
	end

	# Static function to get the unique argument passed by Yate at start time
	# @return First (and only) command line argument passed by Yate
	def self.arg
		ARGV.each{ |arg|
			return arg
		}
		return nil
	end

	# Static function to convert a Yate string representation to a boolean
	# @param str String value to convert
	# @return True if str is "true", false otherwise
	def self.str2bool(str)
		return (str == "true") ? true : false
	end

	# Static function to convert a boolean to a Yate string representation
	# @param bool Boolean value to convert
	# @return The string "true" if $bool was true, "false" otherwise
	def self.bool2str(bool)
		return (bool == true) ? "true" : "false"
	end

	# Static function to convert a string to its Yate escaped format
	# @param str String to escape
	# @param extra (optional) Character to escape in addition to required ones
	# @return Yate escaped string
	def self.escape(str, extra = "")
		if str.nil?
			return ""
		end
		if str == true
			return "true"
		end
		if str == false
			return "false"
		end
		str = str + ""
		s = ""
		n = str.length
		for i in (0...n) 
			c = str[i,1]  # str[i] would return the ascii value of the character  -- so same as ?c when c is a character
			if ?c < 32 || c == ':' || c == extra
				c = ?c + 64
				c = c.chr
				s += '%'
			elsif c == '%'
				s += c
			end
			s += c
		end
		return s
	end

	# Static function to convert a Yate escaped string back to a plain string
	# @param str Yate escaped string to unescape
	# @return Unescaped string
	def self.unescape(str)
		s = ""
		n = str.length
		for i in (0...n)
			c = str[i,1]
			if c == '%'
			    i = i+1
			    c = str[i,1]
			elsif c != '%'
			    c = ?c - 64
			    c = c.chr
			end
		end
		
		s += c
		
		return s
	end

	# Install a Yate message handler
	# @param name Name of the messages to handle
	# @param priority (optional) Priority to insert in chain, default 100
	# @param filtname (optional) Name of parameter to filter for
	# @param filtvalue (optional) Matching value of filtered parameter
	def self.install(name, priority = 100, filtname = nil, filtvalue = nil)
		name = Yate::escape(name)
		if filtname
			filtname = ":#{filtname}:#{filtvalue}"
		end
		_yate_print("%%>install:#{priority}:#{name}#{filtname}")
	end

	# Uninstall a Yate message handler
	# @param name Name of the messages to stop handling
	def self.uninstall(name)
		name = Yate::escape(name)
		_yate_print("%%>uninstall:#{name}")
	end

	# Install a Yate message watcher
	# @param name Name of the messages to watch
	def self.watch(name)
		name = Yate::escape(name)
		_yate_print("%%>watch:#{name}")
	end

	# Uninstall a Yate message watcher
	# @param name Name of the messages to stop watching
	def self.unwatch(name)
		name = Yate::escape(name)
		_yate_print("%%>unwatch:#{name}")
	end

	# Changes a local module parameter
	# @param name Name of the parameter to modify
	# @param value New value to set in the parameter
	def self.setLocal(name, value)
		if value == true || value == false
			value = Yate::bool2str(value)
		end
		name = Yate::escape(name)
		value = Yate::escape(value)
		_yate_print("%%>setlocal:#{name}:#{value}")
	end

	# Retrive the value of a named parameter
	# @param key Name of the parameter to retrive
	# @param defvalue (optional) Default value to return if parameter is not set
	# @return Value of the key parameter or defvalue
	def getValue(key, defvalue = nil)
		if @params.has_key?(key)
			return @params[key]
		end
		return defvalue
	end


	# Set a named parameter
	# @param key Name of the parameter to set
	# @param value Value to set in the parameter
	def setParam(key, value)
		if value == true || value == false
		value = Yate::bool2str(value)
		end
		@params[key] = value
	end

	# Fill the parameter array from a text representation
	# @param parts A numerically indexed array with the key=value parameters
	# @param offs (optional) Offset in array to start processing from
	def fillParams(parts, offs = 0)
		n = parts.size
		for i in (offs...n)
			s = parts[i]
			q = s.index('=')
			if q.nil?
			@params[Yate::unescape(s)] = nil
			else
			@params[Yate::unescape(s.slice(0,q))] = Yate::unescape(s.slice(q+1, s.length))
			end
		end
	end

	# Dispatch the message to Yate for handling
	# @param message Message object to dispatch
	def dispatch
		if @type != "outgoing"
			Yate::output("Ruby bug: attempt to dispatch message type: " + @type)
			return
		end
		i = Yate::escape(@id)
		t = 0 + @origin
		n = Yate::escape(@name)
		r = Yate::escape(@retval)
		p = ""
		@params.each { |key,item|
		p += ':' + Yate::escape(key,'=') + '=' + Yate::escape(item)
		}
		_yate_print("%%>message:#{i}:#{t}:#{n}:#{r}#{p}")
		@type="dispatched"
	end

	# Acknowledge the processing of a message passed from Yate
	def acknowledge
		if @type != "incoming"
			Yate::output("Ruby bug: attempt to acknowledge message type: " + @type)
			return;
		end
		i = Yate::escape(@id)
		k = Yate::bool2str(@handled)
		n = Yate::escape(@name)
		r = Yate::escape(@retval)
		p = ""
		@params.each { |key,item|
			p += ':' + Yate::escape(key,'=') + '=' + Yate::escape(item)
		}
		_yate_print("%%<message:#{i}:#{k}:#{n}:#{r}#{p}")
		@type="acknowledged"
	end

	# This static function processes just one input line.
	# It must be called in a loop to keep messages running. Or else.
	# @return false if we should exit, true if we should keep running,
	# or an Yate object instance. Remember to use === and !== operators
	# when comparing against true and false.
	def self.getEvent
		if $yate_socket
			begin
				pair = $yate_socket.recvfrom(8192)
				line = pair[0].chomp
			rescue  Errno::EAGAIN => e 
				line = 0
			end
			if (line == 0)
				return true
			end
			# check for error or EOF (must still read this..eof only for TCP sockets)
			if (line == false || line == 0)
				return false
			end
		else
			if $yate_stdin == false
				return false
			end
			# check for EOF
			if $yate_stdin.eof?
				return false
			end
			begin
				line = $yate_stdin.gets("\n")
			rescue
				return true
			end
		end
		line = line.gsub("\n","")
		if line == ""
			return true
		end
		ev = true
		part= line.split(":")
		case part[0]
		when "%%>message"
			# incoming message str_id:int_time:str_name:str_retval[:key=value...]
			ev = Yate.new(Yate::unescape(part[3]),Yate::unescape(part[4]),Yate::unescape(part[1]))
			ev.type = "incoming"
			ev.origin = 0 + part[2].to_i
			ev.fillParams(part,5)
		when "%%<message"
			# message answer str_id:bool_handled:str_name:str_retval[:key=value...]
			ev = Yate.new(Yate::unescape(part[3]),Yate::unescape(part[4]),Yate::unescape(part[1]))
			ev.type = "answer"
			ev.handled = Yate::str2bool(part[2])
			ev.fillParams(part,5)
		when "%%<install"
			# install answer num_priority:str_name:bool_success
			ev = Yate.new(Yate::unescape(part[2]),"",0 + part[1].to_i)
			ev.type = "installed"
			ev.handled = Yate::str2bool(part[3])
		when "%%<uninstall"
			# uninstall answer num_priority:str_name:bool_success
			ev = Yate.new(Yate::unescape(part[2]), "",0 + part[1].to_i)
			ev.type = "uninstalled"
			ev.handled = Yate::str2bool(part[3])
		when "%%<watch"
			# watch answer str_name:bool_success
			ev = Yate.new(Yate::unescape(part[1]))
			ev.type = "watched"
			ev.handled = Yate::str2bool(part[2])
		when "%%<unwatch"
			# unwatch answer str_name:bool_success
			ev = Yate.new(Yate::unescape(part[1]))
			ev.type = "unwatched"
			ev.handled = Yate::str2bool(part[2])
		when "%%<connect"
			# connect answer str_role:bool_success
			ev = Yate.new(Yate::unescape(part[1]))
			ev.type = "connected"
			ev.handled = Yate::str2bool(part[2])
		when "%%<setlocal"
			# local parameter answer str_name:str_value:bool_success
			ev = Yate.new(Yate::unescape(part[1]),Yate::unescape(part[2]))
			ev.type = "setlocal"
			ev.handled = Yate::str2bool(part[3])
		when "Error in"
			# We are already in error so better stay quiet
		else
			Yate::output("Ruby parse error: " + line)
		end
		return ev
	end


	# This static function initializes globals in the Ruby Yate External Module.
	# ?? It should be called before any other method.
	# @param async (optional) True if asynchronous, polled mode is desired
	# @param addr Hostname to connect to or UNIX socket path
	# @param port TCP port to connect to, zero to use UNIX sockets
	# @param role Role of this connection - "global" or "channel"
	# @return True if initialization succeeded, false if failed
	def self.init(async = false, addr = nil, port = 0, role = nil)
		$yate_debug = false
		$yate_stdin = false
		$yate_stdout = false
		$yate_stderr = false
		$async = async
		if addr
			ok = false
			sock_addr = Socket.pack_sockaddr_in(port,addr)
			if port != 0
				$yate_socket = Socket.new(AF_INET,SOCK_STREAM,SOL_TCP)
				begin
					$yate_socket.connect(sock_addr)
					ok = true
				rescue
					ok = false
				end
			else
				$yate_socket = Socket.new(AF_UNIX,SOCK_STREAM,0)
				begin
					$yate_socket.connect(sock_addr)
				rescue
					ok = false
				end
			end
			if $yate_socket.nil? || ok == false
				$yate_stderr = IO.new(2,"w")
				Yate::output("Socket error, initialization failed")
				return false
			else
				#$yate_socket.flush
			end
		else
			$yate_socket = false
			$yate_stdin = IO.new(0,"r") 	#stdin
			$yate_stdout = IO.new(1,"w")    # stdout
			$yate_stderr = IO.new(2,"w")    # stderr
			$yate_stdout.sync = true
			$yate_stderr.sync = true
			$role = ""
			$yate_stdout.flush
		end
		if role
			_yate_print("%%>connect:#{role}\n")
		end
		return true
	end

	# Constructor. Creates a new outgoing message
	# @param name Name of the new message
	# @param retval (optional) Default return
	# @param id (optional) Identifier of the new message
	def initialize(name, retval = '', id = '')
		if id == ""
			id = Yate::uniqid
		end
		@type = "outgoing"
		@name = name
		@retval = retval
		@origin = Time.now.to_i
		@handled = false
		@id = id
		@params = Hash.new
	end

	# Get an unique id for a message
	# @param prefix String to be added at the beggining of the id
	# @return String represented the generated id
	def  self.uniqid(prefix = '')
		sec = Time.now.tv_sec
		usec = Time.now.tv_usec % 0x100000
		return sprintf("%s%08x%05x", prefix, sec, usec)
	end
end

# Not used yet!! Didn't find a way to set it
# Internal error handler callback - output plain text to stderr
def _yate_error_handler(errno, errstr, errfile, errline)
	str = " [#{errno}] #{errstr} in #{errfile} line #{errline}\n"
	case errno
	when E_USER_ERROR
		Yate::output("Ruby fatal: #{str}")
		exit(1)
	when E_WARNING
	when E_USER_WARNING
		Yate::output("Ruby error: #{str}")
	when E_NOTICE
	when E_USER_NOTICE
		Yate::output("Ruby warning: #{str}")
	else
		Yate::output("Ruby unknown error: #{str}")
	end
end

# Internal function
def _yate_print(str)
	if $yate_socket != false
		$yate_socket.puts(str)
		$yate_socket.flush
	elsif $yate_stdout != false
		$yate_stdout.puts(str)
		$yate_stdout.flush
	end
end