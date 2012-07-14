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
 An Issue object contains all the data of an issue
=end
class Issue
  
  require "connect"
  
  # issue type of the issue 
  attr_reader :issuetype
  # project the issue belongs to
  attr_reader :project
  
=begin
  New initialize method we take the project and the type we want to use and take login info that might exist just right with us
  project Name of the project this issue is to live in
=end
  def initialize (project,type,credentials)
    connection = Connect.new(credentials)
    query = {:projectKeys => project, :issuetypeNames => type, :expand => "projects.issuetypes.fields" }
    jhash = connection.execute("Get","issue/createmeta/",query)
    parse_json(jhash)
    raise Jirarest2::WrongProjectException, project if @project == ""
    raise Jirarest2::WrongIssuetypeException, type if @issuetype == ""
  end

=begin
 It needs the hashed version of the json-snippet jira returns
 It produces an instance-variable @issuefields that can be 
=end
  def parse_json (jhash)
    @issuefields = Hash.new
    @project = ""
    @issuetype = ""
    jhash["projects"].each { |value|
      @project = value["key"]
      value["issuetypes"].each { |value|
        @issuetype = value["name"]
        value["fields"].delete("project") #The project key is duplicate and will make us live harder afterwards. It is marked as required but nothing happens if this key is not set.
        value["fields"].each { |key,value|
          fields = Hash.new
          fields["id"] = key
          if value["name"] then
            name = value["name"]
          else
            name = key
          end
          # If the allowed reponses are limited we want to know them.
          if value["allowedValues"] then
            # With custom fields the identifier is "value" with the built in ones it's "name"
            identifier = "name"
            if value["schema"]["custom"] then
              identifier = "value"
            end
            allowedValues = Array.new
            value["allowedValues"].each { |value|
              allowedValues << value[identifier]
            }
            fields["allowedValuesIdentifier"] = identifier
            fields["allowedValues"] = allowedValues
          end
          fields["required"] = value["required"] 
          fields["type"] = value["schema"]["type"]
          @issuefields[name] = fields if name != "Issue Type" # "Issue Type" is not really a required field as we have to assign it at another place anyway
        }
      }
    }
  end
  
=begin
 Return the type of a field
=end
  def fieldtype(field)
    # If the fieldname is wrong we want to tell this and stop execution (or maybe let the caller fix it)
    if @issuefields[field].nil? then
      raise Jirarest2::WrongFieldnameException, field
    else
      return @issuefields[field]["type"]
    end
  end
  
=begin
 Return all the fields that are required for this issuetype
=end
  def get_requireds
    names = Array.new
    @issuefields.each {|key,value|
      if value["required"] then
        names << key
      end
    }
    return names
  end

=begin
 Return all the names of the fields
=end
  def get_fieldnames
    names = Array.new
    @issuefields.each {|key,value|
        names << key
    }
    return names
  end

=begin
 return the id of a field name
=end
  protected
  def get_id(name)
    return @issuefields["name"]["id"]
  end

=begin
 return a hash that can be sent to jira
Lets create a new issue
query=
{"fields"=>
  { "project"=>{"key"=>"MFTP"}, 
    "environment"=>"REST ye merry gentlemen.", 
    "My own text"=>"Creating of an issue using project keys and issue type names using the REST API",
    "issuetype"=> {"name"=>"My own type"}
  }
}
=end
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

=begin
 checks if the value is allowed for this field
=end
  protected
  def value_allowed?(key,value)
    if @issuefields[key]["allowedValues"].include?(value) 
      return true
    else
      raise Jirarest2::ValueNotAllowedException, @issuefields[key]["allowedValues"]
      puts "Value #{value} not allowed for field #{key}."
    end
  end

=begin
 Special setter for fields that have a limited numer of allowed values.

 This setter might be included in set_field at a later date.
=end
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

=begin
  Setter fuer die Felder des Issues
  :key is the name of the field
  :value is is the value the field should get , this is either a String or an Array (don't know if numbers work too)
TODO We are not yet able to work with "Cascading Select" fields ( "custom": "com.atlassian.jira.plugin.system.customfieldtypes:cascadingselect")
=end
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

=begin
  Get the value of a certain field
=end
  def get_field(field)
    @issuefields[field]["value"]
  end

=begin
 create a new ticket
=end
  def persist(credentials)
    get_requireds.each { |fieldname| 
      if @issuefields[fieldname]["value"].nil? then
        raise Jirarest2::RequiredFieldNotSetException, fieldname
      end
    }
    connection = Connect.new(credentials)
    hash = jirahash
    return connection.execute("Post","issue/",hash)
  end


end


