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

=begin
  An IssueLinkType Object represents one or all IssueLinkTypes
=end
class IssueLinkType < Services

=begin
  We expect to receive an existing 
  :connection
=end
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
=begin
  do the search for each block
=end
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
=begin
  Get the internal name and direction instead of the one in the UI.
  Returns an Array with the name and the direction ("inward" or "outward") if successfull , nil if not
=end
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

=begin
  Is the name realy the internal name we need to use?
=end
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
