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

require "jirarest2/connect"
require "jirarest2/services"

#  Watchers do have their own calling
class Comment < Services

  #  Set our uritail
  # @param [Connection] connection 
  # @param [String] issueid The id or key of the issue in question
  def initialize(connection, issueid, commentid = nil)
    if commentid then
      @uritail = "issue/#{issueid}/comment/#{commentid}"
    else
      @uritail = "issue/#{issueid}/comment"
    end
    super(connection)
  end

  # Add a comment to an issue
  # @param [String] text to add
  def add(text)
    post({"body" => text})
  end
  
  # Return all the watchers of the issue
  # @return [String] Usernames of watching users
  def get_watchers
    ret = get
    watchers = Array.new
    ret["watchers"].each { |entry|
      watchers << entry["name"]
    }
    return watchers
  end
  

  # Adds a new watcher for the issue
  # @param [String] username Username of the new watcher
  # @return [Boolean] Success
  def add_watcher(username)
    ret = post(username)
    case ret.code
    when "204"
      return true
    else
      return false
    end
  end


  # remove one watcher from the issue
  # @param [String] username Username of the watcher to delete
  # @return [Boolean] Success
  def remove_watcher(username)
    query = {"username" => username}
    ret = delete(query)
    case ret.code # Have to decide what to do here (Work with exceptions or with the case block)
    when "204"
      return true
    else
      false
    end
  end

end
