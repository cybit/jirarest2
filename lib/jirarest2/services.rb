# Services super class (what the services themselves can do is mostly the same)
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

require_relative "connect"

#  Trying to keep the services together in one class so I don't have to write so much
class Services

  # @param [Connection] connection A connection Object
  def initialize(connection)
    @connection = connection
# to be set in each subclass;
#    @uritail = ""
  end

  # Send the GET request
  # @param [Hash,String] data to be sent to Connection.execute
  # @return [Hash] The result as constructed by Connection.execute transformed from a json hash
  def get(data = "")
    return @connection.execute("Get",@uritail,data).result
  end
  

  # Send the POST request
  # @param [Hash] data to be sent to Connection.execute
  # @return [Result] The result as constructed by Connection.execute
  def post(data = "")
    return @connection.execute("Post",@uritail,data)
  end
  
  # Send the DELETE request
  # @param [Hash] data to be sent to Connection.execute
  # @return [Result] The result as constructed by Connection.execute
  def delete(data = "")
    return @connection.execute("Delete",@uritail,data)
  end

  # Send the PUT request
  # @param [HASH] data to be sent to Connection.execute
  # @return [Hash] The result as constructed by Connection.execute transformed from a json hash
  def put(data = "")
    return @connection.execute("Put",@uritail,data).result
  end

end #class
