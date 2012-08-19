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

require_relative "field"

# Keep track of one Issuetype
class Issuetype
  # Name of the issuetype
  attr_reader :name
  # Description
  attr_reader :description
  # All the fields in this issuetype
  attr_reader :fields
  # All the required fields in this issuetype
  attr_reader :required_fields
  
  #Get the correct Fieldtype based on the schema from createmeta
  # @attr [Hash] schema The type description we get
  # @return [String] Name of the Fieldtype to use
  # @todo timetracking will probably not work
  # @todo attachment is not realy good either
  # @todo hiddenjobswitch is unsure
  # @todo jobcheckbox is unsure
  # @todo check priority type
  # @todo how to handle readonlyfield?
  def decipher_schema(schema) 
    case schema["type"]
    when "number"
      return "NumberField"
    when "user"
      return "UserField"
    when "version"
      return "VersionField"
    when "project"
      return "ProjectField"
    when "issuetype"
      return "HashField"
    when "datetime"
      return "DateTimeField"
    when "date"
      return "DateField"
    when "priority"
      return "HashField"
    when "group"
      return "UserField"
    when "resolution"
      return "HashField"
    when "timetracking"
      return "TextField"
    when "array"
      case schema["items"]
      when "version"
        return "MultiVersionField"
      when "group"
        return "MultiUserField"
      when "attachment"
        return "MultiStringField"
      when "user"
        return "MultiUserField"
      when "component"
        return "MultiHashField"
      when "string"
        return "MultiStringField" if schema["system"] && schema["system"] == "labels" # This is the only field with the "system" attribute
        case schema["custom"] 
        when /.*:multicheckboxes$/
          return "MultiHashField"
        when /.*:multiselect$/
          return "MultiHashField"
        when /.*:cascadingselect$/
          return "CascadingField"
        else
          raise Jirarest2::CouldNotDetermineFieldtypeException schema
        end
      else
        raise Jirarest2::CouldNotDetermineFieldtypeException schema
      end
    when "string"
      return "TextField" if schema["system"]
      schema["custom"] =~ /.*:(\w*)$/
      case $1
      when "url"
        return "TextField"
      when "textfield"
        return "TextField"
      when "textarea"
        return "TextField"
      when "radiobuttons"
        return "HashField"
      when "select"
        return "HashField"
      when "hiddenjobswitch"
        return "TextField"
      when "readonlyfield"
        return "TextField"
      when "jobcheckbox"
        return "TextField"
      else 
        raise Jirarest2::CouldNotDetermineFieldtypeException schema
      end
    else
      raise Jirarest2::CouldNotDetermineFieldtypeException schema
    end

  end

  # Interpret the result of createmeta for one issuetype
  # @attr [Hash] issuetype The JSON result for one issuetype
  # @todo As the name and not the id of the field is used here some fields might get lost. There should be some way around while still enabling the use of names for external calls
  def createmeta(issuetype)
    @name = issuetype["name"]
    @description = issuetype["description"]
    @fields = Hash.new
    @required_fields = Array.new
    @field_name_id = Hash.new
    issuetype["fields"].each { |id,structure|
      name = structure["name"]
      required = structure["required"]
      type = decipher_schema(structure["schema"])
      field = Jirarest2Field::const_get(type).new(id,name,{:required => required, :createmeta => structure})
      @fields[id]  = field
      @field_name_id[name] = id
      @required_fields << field if required
    }
  end


end # class Issuetype
