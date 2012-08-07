# A Credentials object contains the data required to connect to a JIRA(tm) instance.

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

# A Credentials object contains the data required to connect to a JIRA(tm) instance.
class PasswordCredentials < Credentials

  # password for the connection
  attr_accessor :password

  # @param [String] url URL to JIRA(tm) instance
  # @param [String] username
  # @param [String] password
  def initialize(url,username,password)
    super(url,username)
    @password = password
  end

  # Get the auth header to send to the server
  # @param [Net:::HTTP::Post,Net:::HTTP::Put,Net:::HTTP::Get,Net:::HTTP::Delete] request Request object
  def get_auth_header(request)
    request.basic_auth  @username, @password
  end

end
