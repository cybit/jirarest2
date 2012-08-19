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

require "jirarest2/exceptions"
# All the fieldtypes in their own namespace (hopefully easier in the documentation)
# @todo operations "add","set","remove" are ignored right now.
module Jirarest2Field
  # Superclass for all fields
  class Field
    # Is this field mandatory?
    # @return [Boolean] Default: false. True if your field has to be set for the issuetype
    attr_reader :required
    # Is this field readonly?
    # @return [Boolean] Default: false
    attr_reader :readonly
    # The field id in JIRA(tm)
    # @return [String] The id in your JIRA(tm) instance
    attr_reader :id
    # The name given to the field (not unique in jira!)
    # @return [String] The name in your JIRA(tm) instance
    attr_reader :name
    # Allowed values for the fields
    # @return [Array] The values allowed for this kind of field
    attr_accessor :allowed_values

    # @attr [String] id The fields identifier in JIRA(tm)
    # @attr [String] name The fields name in JIRA(tm)
    # @attr [Hash] args, :required if this is a mandatory field
    def initialize(id,name,args)
      @id = id
      @name = name
      if args[:required] then
        @required = true
      else
        @required = false
      end
      @allowed_values = []
      if args[:allowed_values] then
        allowed_values = args[:allowed_values]
      end
      @value = nil
      @readonly = false
      if args[:createmeta] then
        createmeta(args[:createmeta])
      end
    end
    
    # Get the value of the field
    # @param [Boolean] raw true returns a date Object, false a String
    # @return [String] if raw is false (default)
    # @return [Object] if raw is true
    def value(raw = false)
      return @value
    end

    # Checks if the value is in the list of allowed values. If the list is empty every value is allowed
    # @param [Object] value The value to check for
    # @raise [Jirarest2::ValueNotAllowedException] Raised if the value is not allowed
    # @return [Boolean] true if the value is allowed, false if not
    def value_allowed?(value)
      return true if @allowed_values  == [] # If there is no list get out of here fast
      if @allowed_values.include?(value) then
        return true
      else
        raise Jirarest2::ValueNotAllowedException.new(@name,@allowed_values), "#{value} is not a valid value. Please use one of #{@allowed_values.join("; ").to_s}"
      end
    end

    # Set the value of the field
    # @param [Object] content The value of this field
    def value=(content)
      @value = content if value_allowed?(content)
    end
    
    # Representation to be used for json and jira
    # @param [String,Hash] value the to be put into the representation.
    # @return [Hash] if the value is set
    # @return [Nil] if the value is not set
    def to_j(value = @value)
      if value.nil? then
        return nil
      else 
        return {@id => value}
      end
    end
    
    #Interpret the result of createmeta for one field
    # @attr [Hash] structure  The JSON result for one field
    def createmeta(structure)
      @readonly = true if structure["operations"] == []
      if structure["allowedValues"] then
        structure["allowedValues"].flatten!(1)
        if structure["allowedValues"][0].has_key?("value") then 
          @key = "value"
        elsif structure["allowedValues"][0].has_key?("name") then 
          @key = "name"
        elsif structure["allowedValues"][0].has_key?("key") then
          @key = "key"
        else
          @key = "id"
        end
        structure["allowedValues"].each{ |suggestion|
          @allowed_values << suggestion[@key]
        }
      end
    end

protected
    # Representation to be used for json and jira - don't return the fieldid
    # @param [String,Hash] value the to be put into the representation.
    # @return [String,Hash] if the value is set
    # @return [Nil] if the value is not set
    def to_j_inner(value = @value)
      if value.nil? then
        return nil
      else 
        return value
      end
    end

  end # class Field
  

  
  # A simple text field. JSON representation will be "Fieldid" : "Value"
  class TextField < Field
  end # TextField
  
  # A simple Date field. 
  class DateField < Field
    require "date"

    # Set the value
    # @param [String] content The date in a string representation (Either [YY]YY-[M]M-[D]D or [D]D.[M]M.YYYY or YY.[M]M.[D]D See Date.parse) 
    def value=(content)
      value = Date.parse(content)
      @value = value if value_allowed?(value)
    end

    # Get the value 
    # @param [Boolean] raw true returns a date Object, false a String
    # @return [String] if raw is false (default)
    # @return [Date] if raw is true
    def value(raw = false)
      if raw then
        super
      else
        return @value.to_s
      end
    end
    
    # Representation to be used for json and jira
    # @return [Hash]
    def to_j
      if @value.nil? then
        super(nil)
      else
        super(@value.to_s)
      end
    end

    # Representation to be used for json and jira without the fieldId
    # @return [Hash]
    def to_j_inner
      if @value.nil? then
        super(nil)
      else
        super(@value.to_s)
      end
    end
      
  end # end class DateField

  # A field resembling a DateTime
  class DateTimeField < DateField
#    require "date"

    # Set the value
    # @param [String] content The DateTime in a string representation (Use "YYYY-MM-DD HH:MM:SS" although others like "HH:MM:SS YYYY-MM-DD" or "HH:MM:SS DD.MM.YYYY" work too. See DateTime.parse )
    def value=(content)
      value = DateTime.parse(content)
      @value = value if value_allowed?(value)
    end

#TODO See if Jira behaves as it should. If not the output format has to be forced to YYYY-MM-DDThh:mm:ss.sTZD 
  end #class DateTimeField

  # A field representing Numbers (not Strings with Numbers)
  # @todo See to recognize allowed - might hide in schema
  class NumberField < TextField
    # Set the value
    # @param [String,Fixnum] content A number
    def value=(content)
      if content.instance_of?(String) then
        value = content.to_f 
      else
        value = content
      end
      @value = value if value_allowed?(value)
    end
  end # class NumberField
  
  # A Field that presents its value in an hash that has additional information ("name","id","key","value")
  class HashField < TextField
    # The key element for the answers - It should not be needed - but it's easer on the checks if it's exposed
    # @return [String] The key element for the way to Jira
    attr_reader :key

    # @attr [String] id The fields identifier in JIRA(tm)
    # @attr [String] name The fields name in JIRA(tm)
    # @attr [Hash] args :key ist mandatory and a String,  :required (a Boolean if this is a mandatory field)
    #   (key should be one of "id", "key", "name", "value" )
    # @todo How do we make sure we get the arguments wie need for our keys?
    def initialize(id,name,args)
      @key = args[:key].downcase       if ! args[:createmeta] 
      super
    end
    
    # Representation to be used for json and jira
    # @return [Hash] if value is set
    def to_j(value = @value)
      if value.nil? then
        super(nil)
      else
        valuehash = {@key => value}
        super(valuehash)
      end
    end

    # Representation to be used for json and jira without the fieldID
    # @return [Hash] if value is set
    def to_j_inner(value = @value)
      if value.nil? then
        super(nil)
      else
        valuehash = {@key => value}
        super(valuehash)
      end
    end
  end # class HashField

  # A field containing one or more other fields (usually only TextField or HashField)
  class MultiField < Field
    # @attr [String] id The fields identifier in JIRA(tm)
    # @attr [String] name The fields name in JIRA(tm)
    # @attr [Hash] args, :required if this is a mandatory field
    def initialize(id,name,args)
      super(id,name,args)
      @value = []
      @delete = false
    end

    # Checks if the value is in the list of allowed values. If the list is empty every value is allowed
    # @param [Object] value The value to check for
    # @raise [Jirarest2::ValueNotAllowedException] Raised if the value is not allowed
    # @return [Boolean] true if the value is allowed, false if not
    def value_allowed?(value)
      return true if @allowed_values == [] # If there is no list get out of here fast
      if value.instance_of?(Array) then
        value.each { |entry|
          value_allowed?(entry)
        }
      else
        if @allowed_values.include?(value) then
          return true
        else
          raise Jirarest2::ValueNotAllowedException.new(@name,@allowed_values), "#{value} is not a valid value. Please use one of #{@allowed_values.join("; ").to_s}"
        end
      end
    end
    
    # Set the value of the field
    # @attribute [w] value
    #   @param [Object] content The value of this field
    #   @return [Array] All the contained fields
    def value=(content)
      if ! content.instance_of?(Array) then
        content = [content]
      end
      super(content)
    end

    
    # Return for JSON representation
    # if @value == [] and @delete is false set super will return nil
    def to_j(value = @value)
      if ((value == []) and ! @delete) then
        super(nil)
      else
        value.compact!
        fields = Array.new
        if value[0].class  < Jirarest2Field::Field then
          value.each {|field| 
            fields << field.to_j_inner
          }
        else
          fields = value
        end
        super(fields)
      end
    end
    
    # Delete items
    # @param [Object] object The object to delete (If the object is self it all fields and sets @delete)
    # @return The deleted object
    def delete(object)
      if object == self then
        @delete = true
        @value = []
      else
        @value.delete(object)
      end
    end
    
    # Delete items based on their value attribute
    # @param [Object] ovalue The value that defines the objects to delete from this MultiField
    # @return [Array] The remaining Objects
    def delete_by_value(ovalue)
      @value.delete_if {|x| x.value == ovalue}
    end

    # Add another field to the MultiField
    # @param [Field,String] content the content to add to the hash
    def <<(content)
      
      if @value.length > 0  then
        raise Jirarest2::ValueNotAllowedException.new(@name,@value[0].class), "#{@value[0].class} vs #{content.class}"  if @value[0].class != content.class 
      end
      
      @value << content if value_allowed?(content)
    end
    
    # One field from the MultiField
    # @param [Integer] index Position of the field
    def [](index)
      @value[index]
    end

    # Set the content of one special field
    # @param [Integer] index Position of the field
    # @param [Object] content Value to put at the place marked by index
    # @raise [Jirarest2::ValueNotAllowedException] Raised if Classes of the fields are to be mixed
    def []=(index,content)
      raise Jirarest2::ValueNotAllowedException.new(@name,@value[0].class), "#{@value[0].class} vs #{content.class}" if @value[0].class != content.class 
      @value[index] = content if value_allowed?(content)
    end
  end # class MultiField

  # The class to represent CascadingSelectFields
  class CascadingField < Field
    # The key element for the answers - It should not be needed - but it's easer on the checks if it's exposed
    # @return [String] The key element for the way to Jira
    attr_reader :key
    # @!attribute [w] allowed_values
    #   @attr [Hash<Array>] value The Hashes with the allowed values
    def allowed_values=(value)
      @allowed_values = value
    end

    # Checks if the value is in the list of allowed values. If the list is empty every value is allowed
    # @param [Object] value The value to check for
    # @raise [Jirarest2::ValueNotAllowedException] Raised if the value is not allowed
    # @return [Boolean] true if the value is allowed, false if not
    def value_allowed?(value)
      return true if @allowed_values == []  # If there is no list get out of here fast
      if @allowed_values.has_key?(value[0]) && @allowed_values[value[0]].include?(value[1]) then
        return true
      else
        raise Jirarest2::ValueNotAllowedException.new(@name,@allowed_values), "#{value.to_s} is not a valid value. Please use one of #{@allowed_values}"
      end
    end    

    # Set the value of the field
    # @!attribute [w] value
    #  @param [Array(String,String)] content The value of this field
    #  @raise [Jirarest2::ValueNotAllowedException] Raised if Classes of the fields are to be mixed
    def value=(content)
      if ! content.instance_of?(Array) or content.size != 2 then
        raise Jirarest2::ValueNotAllowedException.new(@name,"Array"), "Needs to be an Array with exactly 2 parameters. Was #{content.class}." 
      end
      super
    end
    

    # Representation to be used for json and jira
    # @return [Hash] if the value is set
    # @return [Nil] if the value is not set
    def to_j
      if @value.nil? then
        super(nil)
      else
        super({"value" => @value[0], "child" => {"value" => @value[1]}})
      end
    end
    
    #Interpret the result of createmeta for one field
    # @attr [Hash](structure)
    # @note fills allowed_values with a straight list of allowed values
    # @todo Nothing is done here yet!
    def createmeta(structure)
      @readonly = true if structure["operations"] == []
      @key = "value"
      if structure["allowedValues"] then
        structure["allowedValues"].each{ |suggestion|
          subentries = Array.new
          suggestion["children"].each{ |entry|
            subentries << entry["value"]
          }
          @allowed_values << {suggestion[@key] => subentries}
        }
      end
    end
  end # class CascadingField
  
  class MultiStringField < MultiField ; end
  class MultiHashField < MultiField 
    # The key element for the answers - It should not be needed - but it's easer on the checks if it's exposed
    # @return [String] The key element for the way to Jira
    attr_reader :key
  end
  class MultiVersionField < MultiHashField ; end 
  # Unfortunately Users and Groups don't give us any clue as to how to set their "key" element. Therefore this own class
  class MultiUserField < MultiHashField 
    def initialize(id,name,args)
      @key = "name"
      super
    end
  end
  
  # Unfortunately Users and Groups don't give us any clue as to how to set their "key" element. Therefore this own class
  class UserField < HashField
    def initialize(id,name,args)
      @key = "name"
      super
    end
  end

  class VersionField < HashField ;  end 
  class ProjectField < VersionField ; end

=begin
  class CascadingSelect < CascadingField ;  end # Look for "custom" Key
  class DateTime < DateTimeField ;  end
  class GroupPicker < HashField ;  end
  class ImportId ; end
  class Labels < MultiStringField ; end 
  class MultiGroupPicker < MultiHashField ; end
  class MultiUserPicker < MultiHashField ; end
  class ProjectPicker < HashField; end
  class ReadOnlyTextField < TextField ; end
  class SingleVersionPicker < HashField ; end
  class URLField < TextField ; end
  class VersionPicker < MultiHashField ; end
  class DatePicker < DateField ; end
  class FreeTextField < TextField ; end
  class HiddenJobSwitch ; end
  class JobCheckbox ; end
  class MultiCheckboxes < MultiField ; end #unsure
  class MultiSelect < MultiHashField ; end
#  class NumberField < NumberField ; end
  class RadioButtons < HashField ; end
  class SelectList < HashField ; end
#  class TextField < TextField ; end
  class UserPicker < HashField ; end

  class String < TextField ; end
  class Progress ; end
#  class Timetracking < TimeTrackingEntry ; end # "timetracking" : { "originalEstimate" : "1w2h", "remainingEstimate" : "3h23m" }
  class Issuetype < HashField ; end
  class Number < NumberField ; end
  class User < UserPicker ; end
#  class Datetime  ; end # See above
  class Priority < TextField ; end
  class Date < DateField ; end
  class Array < MultiField ; end # Never alone always with an items parameter
  class Status ; end
  class Project < HashField ; end 
  class Component ; end
  class Comment ; end
  class Votes ; end
  class Resolution < TextField ; end
  class Version < HashField ; end
  class Watches ; end
  class Worklog ; end
  class Attachment ; end # readonly
=end
end


