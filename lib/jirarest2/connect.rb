# class to handle connections
#    Copyright (C) 2012 Cyril Bitterich
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.
#


require 'net/http'
require 'jirarest2/exceptions'
require 'jirarest2/result'
require "pp"



# A Connect object encasulates the connection to jira via REST. It takes an Credentials object and returns a Jirarest2::Result object or an exception if something went wrong.
class Connect
  
# Create an instance of Connect.
# @param [Credentials] credentials
  def initialize(credentials)
    @pass = credentials.password
    @user = credentials.username
    @CONNECTURL = credentials.connecturl
  end

  

# Execute the request
# @param [String, "Get", "Post", "Delete", "Put"] operation HTTP method:  GET, POST, DELETE, PUT
# @param [String] uritail The last part of the REST URI
# @param [Hash] data Data to be sent.
# @return [Jirarest2::Result]
  def execute(operation,uritail,data)
    uri = nil
    uri = URI(@CONNECTURL+uritail)
    
    if data != "" then
      if operation != "Post" then # POST carries the payload in the body that's why we have to wait
        uri.query = URI.encode_www_form(data)
      end
    end
    
    req = nil
    req = Net::HTTP::const_get(operation).new(uri.request_uri) # "Classes Are Just Obejects, Too" (Design Patterns in Ruby, Russ Olsen, Addison Wessley)
    req.basic_auth @user, @pass
    req["Content-Type"] = "application/json;charset=UTF-8"

    if data != "" then
      if operation == "Post" then # POST carries the payload in the body
        @payload = data.to_json
        req.body = @payload
      end
    end
    
    # Ask the server
    result = Net::HTTP.start(uri.host, uri.port) {|http|
      http.request(req)
    }
    # deal with output
    case result
    when Net::HTTPUnauthorized #No login-credentials oder wrong ones.
      raise Jirarest2::AuthentificationError, result.body
    when Net::HTTPForbidden #Captcha-Time
      #      pp res.get_fields("x-authentication-denied-reason")
      # Result: ["CAPTCHA_CHALLENGE; login-url=http://localhost:8080/login.jsp"]
      result.get_fields("x-authentication-denied-reason")[0] =~ /.*login-url=(.*)/
      raise Jirarest2::AuthentificationCaptchaError, $1
    when Net::HTTPNotFound
      raise Jirarest2::NotFoundError, result
    end
    
    return Jirarest2::Result.new(result)
  end # execute


# Is the rest API really at the destination we think it is?
# @return [Boolean] 
  def check_uri
    begin 
      begin
        ret = (execute("Get","dashboard","").code == "200")
      rescue Jirarest2::NotFoundError
        return false
      end
    end
  end

# Try to be nice. Parse the URI and see if you can find a pattern to the problem
# @param [String] url
# @return [String] a fixed URL
  def heal_uri(url = @CONNECTURL)
    splitURI = URI.split(url) # [Scheme,Userinfo,Host,Port,Registry,Path,Opaque,Query,Fragment]
    splitURI[5].gsub!(/^(.*)2$/,'\12/')
    splitURI[5].gsub!(/\/+/,'/') # get rid of duplicate /
    splitURI[5].gsub!(/(rest\/api\/2\/)+/,'\1') # duplicate path to rest
    splitURI[5].gsub!(/^(.*)\/login.jsp(\/rest\/api\/2\/)$/,'\1\2') # dedicated login page
    splitURI[5].gsub!(/^(.*)\/secure\/Dashboard.jspa(\/rest\/api\/2\/)$/,'\1\2') # copied the dashboard URL (or the login Page)
    if splitURI[3] then
      url = splitURI[0].to_s + "://" + splitURI[2].to_s + ":" + splitURI[3].to_s + splitURI[5].to_s
    else
      url = splitURI[0].to_s + "://" + splitURI[2].to_s + splitURI[5].to_s
    end
    return url
  end


# try to fix the connecturl of this instance 
# @return [String,Jirarest2::CouldNotHealURIError] Fixed URL or Exception
 def heal_uri!
   if ! check_uri then
     @CONNECTURL = heal_uri(@CONNECTURL)
   end
   if check_uri then
     return @CONNECTURL
   else
     raise Jirarest2::CouldNotHealURIError, @CONNECTURL
   end
 end

end # class

=begin

# Add a Key-Value for every search parameter you'd usually have.
query={"jql"=>"project = MFTP", "startAt"=>0, "maxResults"=>4 }
#pp query
# Here we query all those that match our parameter.
#result = get_response("search",query) 
#pp result

=end
