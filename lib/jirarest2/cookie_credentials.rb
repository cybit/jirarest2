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

require_relative "credentials"
require_relative "password_credentials"
require_relative "result"
require_relative "connect"
require "pstore"

# Cookies as credential for the server
# login uses basic auth to log in and then cookies are used
class CookieCredentials < Credentials

  # Location of the file the cookie is persited on a harddrive. Default is "~/.jirarest2.cookie
  attr_accessor :cookiestore

  # @param [String] url URL to JIRA(tm) instance
  # @param [Boolean] autosave Save the cookie on the harddisk whenever something happens?
  def initialize(connecturl, username, autosave = false )
    super(connecturl,username)
    @cookiejar = {}
    @autosave = autosave
    @cookiestore = "~/.jirarest2.cookie"
  end

  # Setup new cookies or update the existing jar.
  # @param [Array] header Header after a request
  def bake_cookies(header)
    return if !header
    header.each do |cookie|
      next unless (pair = cookie.gsub(/[;]*\s*Path=\S+[,]*/,'').split(/\=/)).length == 2
      @cookiejar[pair.first] = pair.last
    end
    store_cookiejar if @autosave    
    return @cookiejar
  end
  
  # Name alias for bake_cookies
  # @param [String] header Header after a request
  def set_cookies(header)
    return bake_cookies(header)
  end

  # Get the cookies in the format to send as header
  def get_cookies
    @cookiejar.map { |cookie| cookie * '=' }.join('; ')
  end

  # Get the auth header to send to the server
  # @param [Net:::HTTP::Post,Net:::HTTP::Put,Net:::HTTP::Get,Net:::HTTP::Delete] request Request object
  # @raise [Jirarest2::AuthenticationError] if there is no JSESSIONID cookie entry 
  # @return [String] Header-Line
  def get_auth_header(request)
    if @cookiejar["JSESSIONID"].nil? then
      raise Jirarest2::CookieAuthenticationError, "No valid cookies"
    end
    if get_cookies == "" then
      # This code should never be executed as the AuthenticationError above will catch more cases
      request["Cookie"] = "JSESSIONID=0" 
    else
      request["Cookie"] = get_cookies 
    end
  end

  # Login per username and password in case the cookie is invalid or missing
  # Uses basic auth to authenticate
  # @param [String] username Username to use for login
  # @param [String] password Password to use for login
  def login(username,password)
    pcred = PasswordCredentials.new(@connecturl,username,password)
    pconnect = Connect.new(pcred)
    result = pconnect.execute("Post","auth/latest/session",{"username" => username, "password" => password})
    bake_cookies(result.header["set-cookie"]) # I already had them seperated into an array.
    return @cookiejar["JSESSIONID"]
  end
  
  # Invalidates the current cookie
  # @return [Boolean] true if successful
  def logout
      con = Connect.new(self)
      ret = con.execute("Delete","auth/latest/session","").code
      store_cookiejar if @autosave
      return true if ret == "204"
  end
  
  # Loads a cookiejar from disk
  def load_cookiejar
    storage = PStore.new(File.expand_path(@cookiestore))
    storage.transaction do
      @cookiejar = storage["cookiejar"]
    end
    @cookiejar = {} if @cookiejar.nil? # Fix a not so nice feature of PStore if it doesn't find content in the file
  end
  
  # Writes the cookiejar to disk
  def store_cookiejar
    storage = PStore.new(File.expand_path(@cookiestore))
    storage.transaction do
      storage["cookiejar"] = @cookiejar 
    end
  end


end
