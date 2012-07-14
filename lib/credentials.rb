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

=begin
 A Credentials object contains the data required to connect to a JIRA(tm) instance.
=end
class Credentials

attr_accessor :username, :password
attr_reader :connecturl

=begin
  Create an instance of Credentials. 
  Requires username, password and the url for the JIRA(tm) instance. (The URL should stop after the port. There is no guarantee it would work if there is any path component given.) 
=end
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

=begin
 Setter for the URL.

 Throws an Jirarest2::NotAnURLError if the given String is not an URI.
=end  
  def connecturl=(url)
    uri = URI(url)
    if uri.instance_of?(URI::HTTP) || uri.instance_of?(URI::HTTPS) then
      @connecturl = url
    else
      raise Jirarest2::NotAnURLError
    end
  end

end
