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


# TODO: These are now someplace else
class AuthentificationError < StandardError
end
class AuthentificationCaptchaError < StandardError
end


class Connect
  

  def initialize(credentials)
    @pass = credentials.password
    @user = credentials.username
    @CONNECTURL = credentials.connecturl
  end

  def do_request (req,uri)
#    pp req.inspect
 #   pp uri
    res = Net::HTTP.start(uri.host, uri.port) {|http|
      http.request(req)
    }
    case res 
    when Net::HTTPUnauthorized #No login-credentials oder wrong ones.
      raise Jirarest2::AuthentificationError, res.body
    when Net::HTTPForbidden #Captcha-Time
      #      pp res.get_fields("x-authentication-denied-reason")
      # Result: ["CAPTCHA_CHALLENGE; login-url=http://localhost:8080/login.jsp"]
      res.get_fields("x-authentication-denied-reason")[0] =~ /.*login-url=(.*)/
      raise Jirarest2::AuthentificationCaptchaError, $1
    end
    return res
  end

  def get_post_response (type,data)
    uri = nil
    uri=URI(@CONNECTURL + type )

    req = nil
    req = Net::HTTP::Post.new(uri.request_uri)
    req.basic_auth @user, @pass
    req["Content-Type"] = "application/json;charset=UTF-8"
    
    if data != "" then
      @payload = data.to_json
      req.body = @payload
    end
    
    result = do_request req, uri
    return JSON.parse(result.body)
  end
  
  def get_get_response(type,data)
    uri = URI(@CONNECTURL+type)
    
    if data != "" then
      uri.query = URI.encode_www_form(data)
    end
    req = Net::HTTP::Get.new(uri.request_uri)
    req.basic_auth @user, @pass
    req["Content-Type"] = "application/json;charset=UTF-8"
    
    result = do_request req, uri
    return JSON.parse(result.body)
  end

def get_response (type,data)
  case type 
  when "issue"
    get_post_response("issue/",data)
  when "search"
    get_post_response("search/",data)
  when "createmeta"
    get_get_response("issue/createmeta",data)
  end
 
end


end

=begin

##
# get the meta info of an issue within a project
def get_issue_meta (project, issuetype)
  query = {:projectKeys => project , :issuetypeNames => issuetype, :expand => "projects.issuetypes.fields" }
  result = get_response("createmeta",query)
end

##
# :method: create_issue
# project, issuetype : String
# fields : Hash
def create_issue ( project, issuetype, fields )
  issuefields = get_issue ()
  
  #query={"fields"=>{"project"=>{"key"=>"MFTP"}, "environment"=>"REST ye merry gentlemen.", "My own text"=>"Creating of an issue using project keys and issue type names using the REST API", "issuetype"=>{"name"=>"My own type"}}}
  #result = get_response("issue",query)
  


end

# This would create a new issue if we'd give the right parameters
#puts get_response("issue",'')

# Add a Key-Value for every search parameter you'd usually have.
query={"jql"=>"project = MFTP", "startAt"=>0, "maxResults"=>4 }
#pp query
# Here we query all those that match our parameter.
#result = get_response("search",query) 
#pp result

# And now we try to find the metadata
#result = get_response("createmeta","")

# Get the Metadata to a special Project and a special Type identified by name (ids would be available with other data)
query = {:projectKeys => "MFTP" , :issuetypeNames => "My own type" }
result = get_response("createmeta",query)
#pp result 

# Extend the above query to get all Data
query = {:projectKeys => "MFTP" , :issuetypeNames => "My own type", :expand => "projects.issuetypes.fields" }
result = get_response("createmeta",query)

#pp result



fields = get_issuefields result
# pp fields
requireds = get_requireds (fields)
pp requireds
=end
