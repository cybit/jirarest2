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

  # username to use
  attr_accessor :username
  # password for the connection
  attr_accessor :password
  # url to connect to the JIRA(tm) instance
  attr_reader :connecturl


  # @param [String] url URL to JIRA(tm) instance
  # @param [String] username
  # @param [String] password
  def initialize(url,username,password)
    @username = username
    @password = password
    uri = URI(url)
    if uri.instance_of?(URI::HTTP) || uri.instance_of?(URI::HTTPS) then
      @connecturl = url
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

end
