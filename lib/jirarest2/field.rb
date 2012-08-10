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
    def to_j
    end
  end
  
  # A simple text field. JSON representation will be "Fieldid" : "Value"
  class TextField < Field

    # Representation to be used for json and jira
    # @param [String,Hash] value the to be put into the representation.
    # @return [Hash]
    def to_j(value = @value)
      return {@id => value}
    end
  end
  
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
      return {@id => @value.to_s}
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
    # @return [Hash]
    def to_j(value = @value)
      valuehash = {@key => value}
      return super(valuehash)
    end

  end # class HashField
end


