# class to get the credentials together
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


require "uri"

# A Credentials object contains the data required to connect to a JIRA(tm) instance.
class Credentials

  # url to connect to the JIRA(tm) instance
  attr_reader :connecturl
  # username to use
  attr_accessor :username
  # basepath for the REST methods
  attr_reader :baseurl

  # @param [String] url URL to JIRA(tm) instance
  def initialize(url,username)
    uri = URI(url)
    if uri.instance_of?(URI::HTTP) || uri.instance_of?(URI::HTTPS) then
      @connecturl = url
      @username = username
      @baseurl = @connecturl.gsub(/rest\/api\/.+/,"rest/")
    else
      raise Jirarest2::NotAnURLError
    end
  end

  # Throws an Jirarest2::NotAnURLError if the given String is not an URI.
  # @param [String] url
  def connecturl=(url)
    uri = URI(url)
    if uri.instance_of?(URI::HTTP) || uri.instance_of?(URI::HTTPS) then
      @connecturl = url
    else
      raise Jirarest2::NotAnURLError
    end
  end
  
  # Get the auth header to send to the server
  # @param [Net:::HTTP::Post,Net:::HTTP::Put,Net:::HTTP::Get,Net:::HTTP::Delete] request Request object
  def get_auth_header(request)

  end

end
