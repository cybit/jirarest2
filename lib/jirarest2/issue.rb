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

# represent an issue
class Issue
  #Person the issue is assigned to
  attr_reader :assignee

  # @param [String] issueid Key or ID of the issue
  def initialize(issueid)
    @issueid = issueid
  end
  
  # Receive an issue and all it's fields from jira
  # @param [Connection] connection
  def receive(connection)
    uritail = "issue/#{@issueid}"
    result = connection.execute("Get",uritail,{"expand" => "metadata"}) # get the issue AND the metadata because we already know how to parse that.
# TODO Many and more fields
  end

  # Set an assignee to an issue
  # @param [Connection] connection
  # @param [String] name Username of the new Assignee, Defaultassignee if "-1" is given
  # @param [Nil] name Deletes Assignee
  # @return [Boolean] true if successfull, false if not
  def set_assignee(connection, name)
    uritail = "issue/#{@issueid}/assignee"
    if ! name.nil? then
      setname = {"name" => name}
    else
      setname = nil
    end
    retcode = connection.execute("Put",uritail,setname).code
    if retcode == "204" then
      @assignee = name
      return true
    else
      return false
    end
  end

  # Deletes an assignee. It actually only calls set_assignee with name = nil .
  # @param [Connection] connection
  def remove_assignee(connection)
    set_assignee(connection, nil)
  end

  # Interpret the result of createmeta for one issuetype
  # @attr [Hash] issuetype one issutype resulting from createmeta
  def createmeta(issuetype)
    @name = issuetype
  end

end # Issue
