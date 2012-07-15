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
  
  
=begin
 Return all the watchers of the issue
=end
  def get_watchers
    ret = @connection.execute("Get",@uritail,"").result
    watchers = Array.new
    ret["watchers"].each { |entry|
      watchers << entry["name"]
    }
    return watchers
  end
  
=begin
  Adds a new watcher for the issue
=end
  def add_watcher(username)
    ret = @connection.execute("Post",@uritail,username)
    case ret.code
    when "204"
      return true
    else
      return false
    end
  end

=begin
  removes one watcher from the issue
=end
  def remove_watcher(username)
    query = {"username" => username}
    ret = @connection.execute("Delete",@uritail,query)
    case ret.code # Have to decide what to do here (Work with exceptions or with the case block)
    when "204"
      return true
    else
      false
    end
  end

end
