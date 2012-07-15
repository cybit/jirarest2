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

require "connect"
=begin
  Trying to keep the services together in one class so I don't have to write so much
=end
class Services

=begin
  We expect to receive an existing 
  :connection
=end
  def initialize(connection)
    @connection = connection
# to be set in each subclass;
#    @uritail = ""
  end

=begin
 Send the GET request
=end
  def get(data = "")
    return @connection.execute("Get",@uritail,data).result
  end
  
=begin
 Send the POST request
=end
  def post(data = "")
    return @connection.execute("Post",@uritail,data)
  end  

=begin
 Send the DELETE request
=end
  def delete(data = "")
    return @connection.execute("Delete",@uritail,data)
  end

end #class
