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
  # @return [String] The name of the issuetype
  attr_reader :name
  # @return [String] The description for this issuetype
  attr_reader :description
  # @return [Array<Hash>] All the fields in this issuetype
  attr_reader :fields
  # @return [Array] All the required fields in this issuetype
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
      return "TimetrackingField"
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

  end # def decipher_schema

  # Interpret the result of createmeta for one issuetype
  # @attr [Hash] issuetype The JSON result for one issuetype
  # @raise [Jirarest2::WrongIssuetypeException] Raised if the issuetype is not found in the answer
  # @todo As the name and not the id of the field is used here some fields might get lost. There should be some way around while still enabling the use of names for external calls
  def createmeta(issuetype)
    if issuetype.nil? || issuetype["name"].nil? then
      raise Jirarest2::WrongIssuetypeException
    else
      @name = issuetype["name"]
    end
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

  
  # Interpret the result to the request for an existing issue
  # @attr [Hash] json The hashed json body of the request
  # @raise [Jirarest2::FieldsUnknownError] Raised if the fields to this issuetype is unknown
  # @todo Is this not really Issue instead of Issuetype?
  # @todo I need name of the issuetype if possible
  def decode_issue(json)
    if (@fields.nil? or @fields == {}) then 
      # Prepare the fields
      if json.has_key?("schema") then
        createmeta(json["schema"])
      elsif  json.has_key?("editmeta") then
        createmeta(json["editmeta"])
      else
        # We need to know what to fill and how
        raise Jirearesr2::FieldsUnknownError json["self"]
      end
    end
    @issuekey = json["key"]
    json["fields"].each{ |field_id,content|
      @fields["field_id"].parse_value(content)
    }
  end # def decode_issue


  #Set the value of a field
  # @param [String] id The name of the field
  # @param [String,Array] value The value of the field
  # @param [Symbol] denom Field identifier to use (:name or :id)
  def set_value(id,value,denom = :name)
    field = get_field(id,denom)
    field.value = value
  end

  # Get the value of a field
  # @param [String] id The name of the field
  # @return [String,Array] value The value of the field
  # @param [Symbol] denom Field identifier to use (:name or :id)
  def get_value(id,denom = :name)
    field = get_field(id,denom)
    return field.value
  end

  

  #check if all the required fields have values
  # The following fields are not seen as required in this method because JIRA (tm) sets it's own defaults: project, issuetype, reporter
  # @param [Boolean] only_empty If set to true will only return those Names where the value is empty
  # @return [Array] Names of all the required_fields that have no value assigned, empty if all fields have a value
  def required_by_name(only_empty = false)
    empty = Array.new
    @required_fields.each{ |field|
      empty << field.name if (field.value.nil? || ! only_empty ) && !field.name.nil? && field.id != "issuetype" && field.id != "reporter" 
    }
    return empty
  end

  #Build up a hash to give to jira to create a new ticket
  # @return [Hash] Hash to be sent to the server
  # @raise [Jirarest2::RequiredFieldNotSetException] Raised if a required field is not set
  # @todo NOT finished
  def new_ticket_hash
    missing_fields = required_by_name(true)
    if missing_fields == [] then
      fields = Hash.new
      @fields.each { |id,field| 
        fields = fields.merge!(field.to_j) if ! field.to_j.nil? #Sending empty fields with a new ticket will not work
      }
      h = {"fields" => fields}
      return h
    else
      raise Jirarest2::RequiredFieldNotSetException, missing_fields
    end
  end

  # Return the fieldtype (Multitype as "array" nostly for backwards compability)
  # @attr [String] fieldname The Name of the field
  # @return [String] The fieldtype as String. MultiField types and CascadingField are returned as "array"
  def fieldtype(fieldname)
    ftype =  get_field(fieldname,:name).class.to_s
    ftype =~ /^.*::(\w+)Field$/
    ftshort = $1
    case ftshort
    when /Multi.*/
      return "array"
    when "Cascading"
      return "array"
    else
      return ftshort
    end
  end
  


private
  # Get the field based on the id and the denominator (:id or :name)
  # @param [String] id The name of the field
  # @param [Symbol] denom Field identifier to use (:name or :id)
  def get_field(id,denom = :name)
    working_id = id
    if denom == :name then
      working_id =  @field_name_id[id] 
    end
    field = @fields[working_id]
    if field.nil? then # Try if it's has been the id all along
      field = @fields[id]
    end
    raise Jirarest2::WrongFieldnameException, id if field.nil?
    return field
  end


end # class Issuetype
