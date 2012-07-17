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
    @all = get
  end

private

  # do the search for each block
  # @param [Hash] hash One LinkIssueType in a hash representation
  # @param [String] uiname the way the linktype is shown in the browser
  # @return [Array] Actual name oft the LinkIssueType
  def name_block_search(hash,uiname)
    name = nil
    direction = nil
    if ( hash["inward"] == uiname) then
      direction = "inward"
      name = hash["name"]
      return name, direction
    elsif (hash["outward"] == uiname) then
      direction = "outward"
      name = hash["name"]
      return name, direction
    else 
      return nil # Save my butt
    end
  end


public

  #Get the internal name and direction instead of the one in the UI.
  # @param [String] uiname the way the linktype is shown in the browser
  # @return [Array, nil] Array with the name and the direction ("inward" or "outward") if successfull , nil if not
  def name(uiname)
    if @all["issueLinkTypes"].instance_of?(Array) then
      @all["issueLinkTypes"].each{ |hash|
        result =  name_block_search(hash,uiname)
        return result if result # Return if we got an actual result
      }
    else
      return name_block_search(@all,uiname)
    end
    return nil # Nothing found don't want to return @all
  end # name

  # Is the name realy the internal name we need to use?
  # @param [String] test String to test agains the names of IssueLinkTypes
  # @return [Boolean] 
  def internal_name?(test)
    if @all["issueLinkTypes"].instance_of?(Array) then
      @all["issueLinkTypes"].each{ |hash|
        return true if ( hash["name"] == test)
      }
    else
      return ( @all["name"] == test )
    end
    return false # Nothing found don't want to return @all
  end

end #class
