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

=begin
# An Issue object contains all the data of an issue
=end
class Issue
    
  # issue type of the issue 
  attr_reader :issuetype
  # project the issue belongs to
  attr_reader :project
  # The issue numer if we got it somehow
  attr_reader :issuekey
  
  # @param [String] project Key of the JIRA(tm) project the issue belongs to
  # @param [String] type Issuetype the issue belongs to
  # @param [Connection] connection
  def initialize (project,type,connection)
    query = {:projectKeys => project, :issuetypeNames => type, :expand => "projects.issuetypes.fields" }
    answer = connection.execute("Get","issue/createmeta/",query)
    jhash = answer.result
    parse_json(jhash)
    raise Jirarest2::WrongProjectException, project if @project == ""
    raise Jirarest2::WrongIssuetypeException, type if @issuetype == ""
  end

  # produces an instance-variable @issuefields that can be 
  # @param [Hash] jhash Hashed version of the json-snippet JIRA(tm) returns
  def parse_json (jhash)
    @issuefields = Hash.new
    @project = ""
    @issuetype = ""
    jhash["projects"].each { |value|
      @project = value["key"]
      value["issuetypes"].each { |value1|
        @issuetype = value1["name"]
        value1["fields"].delete("project") #The project key is duplicate and will make our live harder afterwards. It is marked as required but nothing happens if this key is not set.
        value1["fields"].each { |key,value2|
          fields = Hash.new
          fields["id"] = key
          if value2["name"] then
            name = value2["name"]
          else
            name = key
          end
          # If the allowed reponses are limited we want to know them.
          if value2["allowedValues"] then
            # With custom fields the identifier is "value" with the built in ones it's "name"
            identifier = "name"
            if value2["schema"]["custom"] then
              identifier = "value"
            end
            allowedValues = Array.new
            value2["allowedValues"].each { |value3|
              allowedValues << value3[identifier]
            } # value3
            fields["allowedValuesIdentifier"] = identifier
            fields["allowedValues"] = allowedValues
          end
          fields["required"] = value2["required"] 
          fields["type"] = value2["schema"]["type"]
          @issuefields[name] = fields if name != "Issue Type" # "Issue Type" is not really a required field as we have to assign it at another place anyway
        } # value1
      } # value
    } # jhash
  end
  
  # @param [String] field Name of the field
  # @return [String] type of the Field 
  def fieldtype(field)
    # If the fieldname is wrong we want to tell this and stop execution (or maybe let the caller fix it)
    if @issuefields[field].nil? then
      raise Jirarest2::WrongFieldnameException, field
    else
      return @issuefields[field]["type"]
    end
  end
  
  # @return [Array] Names of required fields
  def get_requireds
    names = Array.new
    @issuefields.each {|key,value|
      if value["required"] then
        names << key
      end
    }
    return names
  end

  # @return [Array] Names of all fields
  def get_fieldnames
    names = Array.new
    @issuefields.each {|key,value|
        names << key
    }
    return names
  end

  # @param [String] name Name of a field
  # @return [String] id of the field
  protected
  def get_id(name)
    return @issuefields["name"]["id"]
  end

=begin
# query=
# {"fields"=>
#  { "project"=>{"key"=>"MFTP"}, 
#    "environment"=>"REST ye merry gentlemen.", 
#    "My own text"=>"Creating of an issue using project keys and issue type names using the REST API",
#    "issuetype"=> {"name"=>"My own type"}
#  }
# }
=end

  # @return [Hash] Hash to be sent to JIRA(tm) in a JSON representation
  public
  def jirahash
    h = Hash.new
    issuetype = {"issuetype" => {"name" => @issuetype}}
    project = {"key" => @project}
    fields = Hash.new
    fields["project"] = project
    # here we need to enter the relevant fields and their values
    @issuefields.each { |key,value|
      if key !=  "project" then
        id = value["id"]
        if ! value["value"].nil? then
          fields[id] = value["value"]
        end
      end
    }
    fields = fields.merge!(issuetype)
    h = {"fields" => fields}
    return h
  end

  # check if the value is allowed for this field
  # @param [String] key Name of the field
  # @param [String] value Value to be checked
  # @return [Boolean, Jirarest2::ValueNotAllowedException]
  protected
  def value_allowed?(key,value)
    if @issuefields[key]["allowedValues"].include?(value) 
      return true
    else
#      puts "Value #{value} not allowed for field #{key}."
      raise Jirarest2::ValueNotAllowedException.new(key, @issuefields[key]["allowedValues"]), value
    end
  end


  # Special setter for fields that have a limited numer of allowed values.
  #
  # This setter might be included in set_field at a later date.
  # @param [String] key Name of the field
  # @param [String] value Value to be checked
  def set_allowed_value(key,value)
    if @issuefields[key]["type"] == "array" && value.instance_of?(Array)  then
      array = Array.new
      value.each {|item|
        if value_allowed?(key,item) then
          array << {@issuefields[key]["allowedValuesIdentifier"] => item}
        end
      }
      @issuefields[key]["value"] = array
    else
      if value_allowed?(key,value) then
        @issuefields[key]["value"] = {@issuefields[key]["allowedValuesIdentifier"] => value}
      end
    end
  end


  # TODO We are not yet able to work with "Cascading Select" fields ( "custom": "com.atlassian.jira.plugin.system.customfieldtypes:cascadingselect")
  # @param [String] key Name of the field
  # @param [String] value Value the field should be set to, this is either a String or an Array (don't know if numbers work too)
  public
  def set_field(key, value)
    if  @issuefields.include?(key) then
      if @issuefields[key].include?("allowedValues") then
        set_allowed_value(key,value)
      else
        @issuefields[key]["value"] = value
      end
    else
      raise Jirarest2::WrongFieldnameException, key
      puts "Unknown Field: #{key}"
    end
  end

  # @param [String] field Name of the field
  # @return [String] value of the field
  def get_field(field)
    @issuefields[field]["value"]
  end

  # persitence of this Issue object instance
  # @param [Connection] connection
  # @return [Jirarest2::Result]
  def persist(connection)
    get_requireds.each { |fieldname| 
      if @issuefields[fieldname]["value"].nil? then
        raise Jirarest2::RequiredFieldNotSetException, fieldname
      end
    }
    hash = jirahash
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

  
end # class
