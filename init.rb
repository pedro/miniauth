begin
	miniauth = YAML.load(File.read("#{RAILS_ROOT}/config/miniauth.yml"))
rescue Errno::ENOENT
	puts "Could not read from config/miniauth.yml."
	puts "Specify users and passwords in this file. Example:"
	puts "john:\n  secret\ndave:\n  12345"
	exit 1
end

if miniauth.class != Hash || miniauth.empty?
	puts "Invalid auth spec in config/miniauth.yml."
	puts "Specify users and passwords in a hash. Example:"
	puts "john:\n  secret\ndave:\n  12345"
	exit 2
end

ActionController::Base.send(:class_variable_set, '@@miniauth', miniauth)

class ActionController::Base
	before_filter :miniauth

	def miniauth
		authenticate_or_request_with_http_basic do |username, password|
			@@miniauth.include?(username) && @@miniauth[username].to_s == password
		end
	end
end