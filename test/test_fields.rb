require "minitest/autorun"
require "jirarest2/field"
require "deb"

module Jirarest2
  class TestField < MiniTest::Unit::TestCase
    def setup
      @fieldid = "FieldID" if @fieldid.nil?
      @fieldname = "Fieldname" if @fieldname.nil?
      if @fieldrequired.nil? then
        @fieldargs = Hash.new
        @fieldrequired = false
      end
      @fieldargs[:required] = @fieldrequired

      @fieldtype = "Field" if @fieldtype.nil?
      @field = eval(@fieldtype).new(@fieldid,@fieldname,@fieldargs) 
    end
    
    def test_required
      assert_equal @fieldrequired,@field.required
    end
    
    def test_id
      assert_equal @fieldid,@field.id
    end
    
  end # class TestField
  
  class TestTextField < TestField
    def setup
      @fieldid = "customfield_10101"
      @fieldname = "issuetype"
      @fieldtype = "TextField"
      super
    end
    
    # This could be put to the top class but here it is anchored
    def test_fieldtype
      assert_instance_of Jirarest2::TextField, @field
    end
    
    def test_to_j
      ret = {"customfield_10101" => nil}
      assert_equal ret,@field.to_j
    end

    def test_set_get_value
      @field.value = "Lorem ipsum"
      assert_equal "Lorem ipsum",@field.value
    end

  end # class TestDateField

  class TestDateTimeField < TestField
    def setup
      @fieldid = "customfield_10001"
      @fieldname = "Date Time Field"
      @fieldtype = "DateTimeField"
      super
    end
    
    # This could be put to the top class but here it is anchored
    def test_fieldtype
      assert_instance_of Jirarest2::DateTimeField, @field
    end
    
    def test_set_get_value
      field_string =  "2012-07-31 14:32:26.134"
      fieldiso8601 = "2012-07-31T14:32:26+00:00"
      @field.value = field_string
      assert_equal  fieldiso8601,@field.value
      assert_equal DateTime.parse("2012-07-31T14:32:26.134+00:00"),@field.value(true)
      @field.value = "12-07-31 14:32:26.134"
      assert_equal  fieldiso8601,@field.value
      @field.value = "31.7.2012 14:32:26.134"
      assert_equal  fieldiso8601,@field.value
      @field.value = "12-7-31 14:32:26.134"
      assert_equal  fieldiso8601,@field.value
      @field.value = "14:32:26.134 31.07.2012"
      assert_equal  fieldiso8601,@field.value
      assert_raises(ArgumentError) { @field.value = "7.31.2012 21:24:31" }
    end

    def test_to_j
      ret = {"customfield_10001" => ""}
      assert_equal ret,@field.to_j
      @field.value = "2011-01-31 15:25:34"
      ret = {"customfield_10001" => "2011-01-31T15:25:34+00:00"}
      assert_equal ret,@field.to_j
    end
  end # class TestDateTimeField

  class TestHashField < TestField
    def setup
      @fieldid = "customfield_10006"
      @fieldname = "List select"
      @fieldtype = "HashField"
      @fieldrequired = true
      @key = "value"
      @field = HashField.new(@fieldid,@fieldname,{:key => @key, :required => @fieldrequired})
    end
    
    # This could be put to the top class but here it is anchored
    def test_fieldtype
      assert_instance_of Jirarest2::HashField, @field
    end
    
    def test_to_j
      ret = {"customfield_10006" => nil}
      assert_equal ret,@field.to_j
    end

    def test_set_get_value
      @field.value = "Lorem ipsum"
      assert_equal "Lorem ipsum",@field.value
    end

    def test_to_j
      ret = {"customfield_10006"=>{"value"=>nil}}
      assert_equal ret, @field.to_j
      field = Jirarest2::HashField.new("blah","mumbatz",{:key => "name"})
      field.value = "test"
      ret = {"blah"=>{"name" => "test"}}
      assert_equal ret, field.to_j
      field = Jirarest2::HashField.new("badfield","mineme",{:key => "key", :required => true})
      field.value = "MFTP"
      ret = {"badfield"=>{"key" => "MFTP"}}
      assert_equal ret, field.to_j
      field = Jirarest2::HashField.new("idfield","minime",{:key => "id", :required => false})
      field.value = "SP"
      ret = {"idfield"=>{"id" => "SP"}}
      assert_equal ret, field.to_j
    end
    
  end # class TestHashField
  
end
=begin
customfieldtypes to check
"datetime" # DateTimeField
"datepicker" # DateField
"textarea" # TextField
"multicheckboxes"
"cascadingselect"
"select" # HashField
"multiselect"
"textfield" TextField
"multiuserpicker"
NumberField
=end
