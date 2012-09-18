# class to handle new issues (building them up, changing fields, persistence)
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

require_relative "issuetype"

# class to handle new issues (building them up, changing fields, persistence)
class NewIssue 
    
  # issue type of the issue 
  attr_reader :issuetype
  # project the issue belongs to
  attr_reader :project
  # The issue numer if we got it somehow
  attr_reader :issuekey
  
  # @param [String] project Key of the JIRA(tm) project the issue belongs to
  # @param [String] type Issuetype the issue belongs to
  # @param [Connection] connection
  # @raise [Jirarest2::WrongProjectException] Raised of the project type is not found in the answer
  def initialize (project,type,connection)
    query = {:projectKeys => project, :issuetypeNames => type, :expand => "projects.issuetypes.fields" }
    answer = connection.execute("Get","issue/createmeta/",query)
    jhash = answer.result
    begin
      @project = jhash["projects"][0]["key"]
    rescue NoMethodError
      raise Jirarest2::WrongProjectException, project 
    end
    @issue = Issuetype.new
    @issue.createmeta(jhash["projects"][0]["issuetypes"][0])
    @issuetype = @issue.name
  end

  # @return [Array] Names of required fields
  def get_requireds
    return @issue.required_by_name
  end

  # @return [Array] Names of all fields
  def get_fieldnames
    names = Array.new
    @issue.fields.each {|id,field|
      names << field.name
    }
    return names
  end

  # take this classes representation of an issue and make it presentable to JIRA(tm)
  # @return [Hash] Hash to be sent to JIRA(tm) in a JSON representation
  # @deprecated @see Issuetype#new_ticket_hash does the same now
  def jirahash
    return @issue.new_ticket_hash
  end

  # @param [String] key Name of the field
  # @param [String] value Value the field should be set to, this is either a String or an Array (don't know if numbers work too)
  # @raise [Jirarest2::WrongFieldnameException] Raised if the name of the field is not found
  # @todo check if the allowed Values are working now too and if they might throw an exception
  def set_field(key, value)
    @issue.set_value(key,value,:name)
  end

  # @param [String] field Name of the field
  # @return [String] value of the field
  def get_field(field)
    @issue.get_value(field,:name)
  end

  # persitence of this Issue object instance
  # @param [Connection] connection
  # @return [Jirarest2::Result]
  def persist(connection)
    hash = @issue.new_ticket_hash
    ret = connection.execute("Post","issue/",hash) 
    if ret.code == "201" then # Ticket sucessfully created
      @issuekey = ret.result["key"]
    end
    return ret
  end

  # Set the watchers for this Ticket
  # @param [Connection] connection
  # @param [Array] watchers Watchers to be added
  # @return [Boolean] True if successfull for all
  def add_watchers(connection,watchers)
    success = false # Return whether we were successful with the watchers
    watch = Watcher.new(connection,@issuekey)
    watchers.each { |person|
      success = watch.add_watcher(person)
    }
    return success
  end

  # Return the fieldtype (Multitype as "array" nostly for backwards compability)
  # @attr [String] fieldname The Name of the field
  # @return [String] The fieldtype as String. MultiField types and CascadingField are returned as "array"
  def fieldtype(fieldname)
    return @issue.fieldtype(fieldname)
  end
  
end # class
