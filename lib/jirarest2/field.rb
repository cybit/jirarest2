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

require "jirarest2/fields"
require "jirarest2/exceptions"

module Jirarest2
  # Superclass for all fields
  class Field
    # Is this field mandatory?
    attr_reader :required

    #The fields id in JIRA(tm)
    attr_reader :id

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
      @value = nil
    end
    
    # Get the value of the field
    # @param [Boolean] raw true returns a date Object, false a String
    # @return [String] if raw is false (default)
    # @return [Object] if raw is true
    def value(raw = false)
      return @value
    end
    
    # Set the value of the field
    def value=(content)
      @value = content
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
      @value = Date.parse(content)
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
        super (nil)
      else
        super(@value.to_s)
      end
    end

    # Representation to be used for json and jira without the fieldId
    # @return [Hash]
    def to_j_inner
      if @value.nil? then
        super (nil)
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
      @value = DateTime.parse(content)
    end

#TODO See if Jira behaves as it should. If not the output format has to be forced to YYYY-MM-DDThh:mm:ss.sTZD 
  end #class DateTimeField

  class NumberField < TextField
    # Set the value
    # @param [String,Fixnum] content A number
    def value=(content)
      if content.instance_of?(String) then
        @value = content.to_f 
      else
        @value = content
      end
    end
  end # class NumberField
  
  class HashField < TextField

    # @attr [String] id The fields identifier in JIRA(tm)
    # @attr [String] name The fields name in JIRA(tm)
    # @attr [Hash] args :key ist mandatory and a String,  :required (a Boolean if this is a mandatory field)
    #   (key should be one of "id", "key", "name", "value" )
    def initialize(id,name,args)
      @key = args[:key].downcase
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

  class MultiField < Field
    # @attr [String] id The fields identifier in JIRA(tm)
    # @attr [String] name The fields name in JIRA(tm)
    # @attr [Hash] args, :required if this is a mandatory field
    def initialize(id,name,args)
      super(id,name,args)
      @value = []
      @delete = false
    end

    
    # Return for JSON representation
    # if @value == [] and @delete is false set super will return nil
    def to_j(value = @value)
      if ((value == []) and ! @delete) then
        super(nil)
      else
        value.compact!
        fields = Array.new
        if value[0].class  < Jirarest2::Field then
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
      
      @value << content
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
      @value[index] = content
    end
    
    

     
  end
end


