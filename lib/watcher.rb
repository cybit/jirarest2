# Watcher class
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
  Watchers do have their own calling
=end
class Watcher

=begin
  We expect to receive an existing 
  :connection
  :issueid
=end
  def initialize(connection,issueid)
    @connection = connection
    @uritail = "issue/#{issueid}/watchers"
  end
  
  

  def get_watchers
    ret = @connection.execute("Get",@uritail,"")
  end
  
  def set_watcher(username)
    query = 
    ret = @connection.execute("Post",@uritail,query)
  end

  def remove_watcher(username)
    query = {"username" => username}
    ret = @connection.execute("Delete",@uritail,query)
  end

end
