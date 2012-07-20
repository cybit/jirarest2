# 
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

require "services"

# Lets try it by making one class for each issue link type and glue them together in a list
class SingleIssueLinkType
  # @return [String] Name of the Type
  attr_reader :name
  # @return [String] Name of the inward string
  attr_reader :inward
  # @return [String] Name of the outward string
  attr_reader :outward

  # @param [String] name The name of the IssueLinkType
  # @param [String] inward The name used for inward links
  # @param [String] outward The name used for outward links
  def initialize(name,inward,outward)
    @name = name
    @inward = inward
    @outward = outward
  end
end

#  An IssueLinkType Object represents one or all IssueLinkTypes
class IssueLinkType < Services


  # @param [Connection] connection
  # @param [String] data issueLinkType ID 
  # @return [Jirarest2::Result]
  def initialize(connection,data = "")
    if data == "" then
      @uritail = "issueLinkType"
    else
      @uritail = "issueLinkType/#{data}"
    end
    super(connection)
    extract_fields(get) # Build the SingleIssueLinkType classes
  end

private
  # Extract the fieldtypes from the Hash we got from the server
  # As the server does not always return the same structure for single and multi instances we have to do some alignment
  # @param [Hash] jiraresponse Hash built from the JSON JIRA(tm) returned to us
  def extract_fields(jiraresponse)
    @types = Hash.new
    if jiraresponse["issueLinkTypes"].instance_of?(Array) then
      jiraresponse["issueLinkTypes"].each{ |hash|
        @types[hash["name"]] = SingleIssueLinkType.new(hash["name"],hash["inward"],hash["outward"])
      }
    else
      @types[jiraresponse["name"]] = SingleIssueLinkType.new(jiraresponse["name"],jiraresponse["inward"],jiraresponse["outward"])
    end
  end

public

  #Get the internal name and direction instead of the one in the UI.
  # @param [String] uiname the way the linktype is shown in the browser
  # @return [Array, nil] Array with the name and the direction ("inward" or "outward") if successfull , nil if not
  def name(uiname)
    return uiname if @types.has_key?(uiname)  # If the name is already correct just bounce it back
    @types.each { |name,singletype|
      if singletype.inward == uiname then
        return singletype.name, "inward"
      elsif singletype.outward ==  uiname then
        return singletype.name, "outward"
      end
    }
    return nil # Nothing found don't want to return @all      
  end # name

  # Is the name realy the internal name we need to use?
  # @param [String] test String to test agains the names of IssueLinkTypes
  # @return [Boolean] 
  def internal_name?(test)
    @types.has_key?(test)
  end

  # Return all valid issuetypefield entries that we now of
  # @param [String] delimiter Delimiter for the output (if you want ", " or "\n" or ...)
  # @return [String] All the valid answers
  def valid_names(delimiter = ", ")
    answer = Array.new
    @types.each { |name,singletype|
      answer << singletype.name
      answer << singletype.inward
      answer << singletype.outward
    }
    return answer.join(delimiter)
  end

end #class
