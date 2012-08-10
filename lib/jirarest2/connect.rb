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
require "deb"



# A Connect object encasulates the connection to jira via REST. It takes an Credentials object and returns a Jirarest2::Result object or an exception if something went wrong.
class Connect
  # Get the credentials
  attr_reader :credentials

  # Create an instance of Connect.
  # @param [Credentials] credentials
  def initialize(credentials)
    @credentials = credentials
  end

  

  # Execute the request
  # @param [String, "Get", "Post", "Delete", "Put"] operation HTTP method:  GET, POST, DELETE, PUT
  # @param [String] uritail The last part of the REST URI
  # @param [Hash] data Data to be sent.
  # @raise [Jirarest2::BadRequestError] Raised if the servers returns statuscode 400 (bad request)
  # @raise [Jirarest2::PasswordAuthenticationError] Raised if authentication failed (status code 401) and the credentials were username/password based
  # @raise [Jirarest2::CookieAuthenticationError] Raised if authentication failed (status code 401) and the credentials were cookie based
  # @raise [Jirarest2::AuthenticationError] Raised if authentication failed (status code 401) and the credentials were neither cookie or username/password based
  # @raise [Jirarest2::AuthentificationCaptchaError] Raised if the server sends a forbidden status (status code 403) and an login url which means the user needs to answer a captcha
  # @raise [Jirarest2::ForbiddenError] Raised if the server sends a forbidden status (status code 403) and no login url
  # @raise [Jirarest2::NotFoundError] Raised if the server returns statuscode 404 (Not found)
  # @raise [Jirarest2::MethodNotAllowedError] Raised if the server returns statuscode 405 (Method not allowed)
  # @return [Jirarest2::Result]
  def execute(operation,uritail,data)
    uri = nil
    if (uritail == "auth/latest/session" )  then # this is the exception regarding the base path
      uristring = @credentials.baseurl+uritail
    else
      uristring = @credentials.connecturl+uritail
    end
 
    uristring.gsub!(/\/\//,"/").gsub!(/^(http[s]*:)/,'\1/')
    uri = URI(uristring)
    if data != "" then
      if ! (operation == "Post" || operation == "Put") then # POST carries the payload in the body that's why we have to wait
        uri.query = URI.encode_www_form(data)
      end
    end
    
    req = nil
    req = Net::HTTP::const_get(operation).new(uri.request_uri) 
    # Authentication Header is built up in a credential class
    @credentials.get_auth_header(req)

    req["Content-Type"] = "application/json;charset=UTF-8"

    if data != "" then
      if (operation == "Post" || operation == "Put") then # POST and PUT carry the payload in the body
        @payload = data.to_json
        req.body = @payload
      end
    end
    
    # Ask the server
    result = Net::HTTP.start(uri.host, uri.port) {|http|
      http.request(req)
    }
    # deal with output

    if ((result["x-ausername"] != @credentials.username) && (uritail != "auth/latest/session" )) then # this is not the right authentication
      verify_auth # make sure
    end      
    case result
    when Net::HTTPBadRequest # 400
      raise Jirarest2::BadRequestError, result.body
    when Net::HTTPUnauthorized # 401 No login-credentials oder wrong ones.
      if @credentials.instance_of?(PasswordCredentials) then
        raise Jirarest2::PasswordAuthenticationError, result.body
      elsif @credentials.instance_of?(CookieCredentials) then
        raise Jirarest2::CookieAuthenticationError, result.body
      else
        raise Jirarest2::AuthenticationError, result.body
      end
    when Net::HTTPForbidden # 403
      if result.get_fields("x-authentication-denied-reason") && result.get_fields("x-authentication-denied-reason")[0] =~ /.*login-url=(.*)/ then #Captcha-Time
        raise Jirarest2::AuthentificationCaptchaError, $1
      else
        raise Jirarest2::ForbiddenError, result.body
      end
    when Net::HTTPNotFound # 404
      raise Jirarest2::NotFoundError, result.body
    when Net::HTTPMethodNotAllowed # 405
      raise Jirarest2::MethodNotAllowedError, result.body
    end
    ret = Jirarest2::Result.new(result)
    @credentials.bake_cookies(ret.header["set.cookie"]) if @credentials.instance_of?(CookieCredentials)  # Make sure cookies are always up to date if we use them.
    return ret
  end # execute


  # Is the rest API really at the destination we think it is?
  # @return [Boolean] 
  def check_uri
    begin
      ret = (execute("Get","dashboard","").code == "200")
      # TODO is the 404 really possible?
    rescue Jirarest2::NotFoundError 
      return false
    rescue Jirarest2::BadRequestError
      return false
    end
  end

  # Try to be nice. Parse the URI and see if you can find a pattern to the problem
  # @param [String] url
  # @return [String] a fixed URL
  def heal_uri(url = @credentials.connecturl)
    splitURI = URI.split(url) # [Scheme,Userinfo,Host,Port,Registry,Path,Opaque,Query,Fragment]
    splitURI[5].gsub!(/^(.*)2$/,'\12/')
    splitURI[5].gsub!(/[\/]+/,'/') # get rid of duplicate /
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
  # @raise [Jirarest2::CouldNotHealURIError] Raised if the url can not be healed automatically
  # @return [String] Fixed URL 
 def heal_uri!
   if ! check_uri then
     @credentials.connecturl = heal_uri(@credentials.connecturl)
   end
   if check_uri then
     return @credentials.connecturl
   else
     raise Jirarest2::CouldNotHealURIError, @credentials.connecturl
   end
 end

 # Verify that we are authenticated
 # @return [Boolean] true if the authentication seems to be valid (actually it checks if there is a session)
 def verify_auth
   ret =   execute("Get","auth/latest/session","") 
   store_cookiejar if @credentials.instance_of?(CookieCredentials) && @credentials.autosave
   return ret.code == "200" 
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
