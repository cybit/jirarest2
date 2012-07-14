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
require 'json'
require 'exceptions'
require "pp"


=begin
 An Connect object encasulates the connection to jira via REST. It takes an Credentials object and returns a parsed JSON Object as Hash or an exception if something went wrong.
=end
class Connect
  
=begin
 Create an instance of Connect. It needs an Credentials object to be created.
=end
  def initialize(credentials)
    @pass = credentials.password
    @user = credentials.username
    @CONNECTURL = credentials.connecturl
  end

  
=begin
 Execute the request
 * operation = one of Get, Post, Delete, Put
 * uritail = the last part of the REST URI
 * data = data to be sent.
=end
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
    end
    
    return JSON.parse(result.body)
  end # execute


end # class

=begin


# Add a Key-Value for every search parameter you'd usually have.
query={"jql"=>"project = MFTP", "startAt"=>0, "maxResults"=>4 }
#pp query
# Here we query all those that match our parameter.
#result = get_response("search",query) 
#pp result

=end
