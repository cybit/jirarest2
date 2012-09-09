require "minitest/autorun"
require "jirarest2/field"
require "deb"

module Jirarest2Field
  class TestField < MiniTest::Unit::TestCase
    def setup
      @fieldid = "FieldID" if @fieldid.nil?
      @fieldname = "Fieldname" if @fieldname.nil?
      @fieldargs = Hash.new if @fieldargs.nil?
      if @fieldrequired.nil? then
        @fieldrequired = false
      end
      @fieldargs[:required] = @fieldrequired
      @fieldtype = "Field"  if @fieldtype.nil?
      @field = eval(@fieldtype).new(@fieldid,@fieldname,@fieldargs) 
    end
    
    def test_required
      assert_equal @fieldrequired,@field.required
    end
    
    def test_id
      assert_equal @fieldid,@field.id
    end
    
    def test_name
      assert_equal @fieldname,@field.name
    end
    
    def test_allowed
      @field.allowed_values = ["one","two","three","four","mad cow","42"]
      @field.value = "one"
      @field.value = "mad cow"
      assert_raises(Jirarest2::ValueNotAllowedException) { @field.value = 42 }
      assert_raises(Jirarest2::ValueNotAllowedException) { @field.value = "five" }
    end
  end # class TestField
  
  class TestTextField < TestField
    def setup
      @fieldid = "customfield_10101"
      @fieldname = "issuetype"
      @fieldtype = "TextField"
      @fieldargs = Hash.new
      @fieldrequired = true
      super
    end
    
    # This could be put to the top class but here it is anchored
    def test_fieldtype
      assert_instance_of Jirarest2Field::TextField, @field
    end
    
    def test_to_j
#      ret = {"customfield_10101" => nil}
      ret = nil
      assert_equal ret,@field.to_j
      @field.value = "Lorem ipsumus"
      ret = {"customfield_10101"=>"Lorem ipsumus"}
      assert_equal ret,@field.to_j
    end

    def test_set_get_value
      @field.value = "Lorem ipsum"
      assert_equal "Lorem ipsum",@field.value
    end

  end # class TestTextField

  class TestDateTimeField < TestField
    def setup
      @fieldid = "customfield_10001"
      @fieldname = "Date Time Field"
      @fieldtype = "DateTimeField"
      @fieldargs = Hash.new
      @fieldrequired = true
      super
    end
    
    # This could be put to the top class but here it is anchored
    def test_fieldtype
      assert_instance_of Jirarest2Field::DateTimeField, @field
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
    
    def test_allowed
    end

    def test_to_j
      ret = nil
      assert_equal ret,@field.to_j
      @field.value = "2011-01-31 15:25:34"
      ret = {"customfield_10001" => "2011-01-31T15:25:34+00:00"}
      assert_equal ret,@field.to_j
    end
  end # class TestDateTimeField

  class TestNumberField < TestField
    def setup
      @fieldid = "timespent"
      @fieldname = "Time Spent"
      @fieldtype = "NumberField"
      @fieldargs = Hash.new
      @fieldrequired = false
      super
    end

    # This could be put to the top class but here it is anchored
    def test_fieldtype
      assert_instance_of Jirarest2Field::NumberField, @field
    end

    def test_allowed
      @field.allowed_values = ["one","two","three","four","mad cow","42",13,23,99]
      assert_raises(Jirarest2::ValueNotAllowedException) { @field.value = "one" }
      assert_raises(Jirarest2::ValueNotAllowedException) { @field.value = "mad cow"}
      assert_raises(Jirarest2::ValueNotAllowedException) { @field.value = 42 }
      @field.value = "13"
      assert_equal 13,@field.value
      @field.value = 13
      assert_equal 13,@field.value
    end
    
    def test_set_get_value
      @field.value = 12
      assert_equal 12,@field.value
      @field.value = 12.5
      assert_equal 12.5,@field.value
      @field.value = "12"
      assert_equal 12,@field.value
      @field.value = "12.5"
      assert_equal 12.5,@field.value
    end

    def test_to_j
      assert_equal nil,@field.to_j
      @field.value = "12.54"
      ret = {"timespent" => 12.54}
      assert_equal ret,@field.to_j
      
    end
    
  end # class TestNumberField

  class TestHashField < TestField
    def setup
      @fieldid = "customfield_10006"
      @fieldname = "List select"
      @fieldtype = "HashField"
      @fieldargs = Hash.new
      @fieldrequired = true
      @key = "value"
      @field = HashField.new(@fieldid,@fieldname,{:key => @key, :required => @fieldrequired})
    end
    
    # This could be put to the top class but here it is anchored
    def test_fieldtype
      assert_instance_of Jirarest2Field::HashField, @field
    end
    
    def test_set_get_value
      @field.value = "Lorem ipsum"
      assert_equal "Lorem ipsum",@field.value
    end

    def test_to_j
      ret = nil
      assert_equal ret, @field.to_j
      field = Jirarest2Field::HashField.new("blah","mumbatz",{:key => "name"})
      field.value = "test"
      ret = {"blah"=>{"name" => "test"}}
      assert_equal ret, field.to_j
      field = Jirarest2Field::HashField.new("badfield","mineme",{:key => "key", :required => true})
      field.value = "MFTP"
      ret = {"badfield"=>{"key" => "MFTP"}}
      assert_equal ret, field.to_j
      field = Jirarest2Field::HashField.new("idfield","minime",{:key => "id", :required => false})
      field.value = "SP"
      ret = {"idfield"=>{"id" => "SP"}}
      assert_equal ret, field.to_j
    end
    
  end # class TestHashField
  
  class TestMultiField < TestField
    def setup
      @fieldid = "customfield_10006"
      @fieldname = "List select"
      @fieldtype = "MultiField"
      @fieldargs = Hash.new
      @fieldrequired = false
      super
    end
    
    # This could be put to the top class but here it is anchored
    def test_fieldtype
      assert_instance_of Jirarest2Field::MultiField, @field
    end
    
    def test_allowed_set
      @field.allowed_values = ["one","two","three","four","mad cow","42"]
      @field.value = "one"
      assert_equal ["one"],@field.value
      @field.value = "mad cow"
      assert_equal ["mad cow"],@field.value
      @field.value = ["one","three","42"]
      assert_equal ["one","three","42"],@field.value
      assert_raises(Jirarest2::ValueNotAllowedException) { @field.value = ["one","five","42"] }
      assert_raises(Jirarest2::ValueNotAllowedException) { @field.value = ["one","two",42] }
      assert_raises(Jirarest2::ValueNotAllowedException) { @field.value = 42 }
      assert_raises(Jirarest2::ValueNotAllowedException) { @field.value = "five" }
    end

    def test_allowed_push
      @field.allowed_values = ["one","two","three","four","mad cow","42",55,42,35,88,67]
      @field.value = [55,42,35,88]
      assert_raises(Jirarest2::ValueNotAllowedException) { @field[1] = "42" }
      assert_raises(Jirarest2::ValueNotAllowedException) { @field[1] = 23 }
      @field[1] = 67
      assert_equal [55, 67, 35, 88],@field.value
    end
    
    def test_set_get_value 
      @field.value = "Lorem ipsum"
      assert_equal ["Lorem ipsum"],@field.value
      test = ["number1","number2"]
      @field.value = test
      assert_equal test,@field.value
      test = [HashField.new("bugger","Big Bugger",{:key => "name"}),HashField.new("snigger","Snigger",{:key => "name"})]
      @field.value = test
      assert_equal test,@field.value
    end

    def test_delete
      @field.value = ["ene","mine","mo","minki","pinki","poo"]
      @field.delete("mo")
      assert_equal ["ene","mine","minki","pinki","poo"],@field.value
      @field.delete(@field)
      assert_equal [],@field.value
    end
    def setup_an_array
      h1 = HashField.new("custom42","Big Bugger",{:key => "name"})
      h2 = HashField.new("custom44","Snigger",{:key => "name"})
      h3 = HashField.new("custom10056","Bloop",{:key => "id"})
      h4 = HashField.new("custom66","snoop",{:key => "id"})
      h1.value = "me"
      h2.value = "minime"
      h3.value = "me"
      h4.value = "moooo"
      @test = [h1,h2,h3,h4]
      @field.value = [h1,h2,h3,h4]
    end
    
    def test_delete_by_value
      setup_an_array
      h1 = @test[0]
      h3 = @test[2]
      h4 = @test[3]
      assert_equal [h1,h3,h4],@field.delete_by_value("minime")
      assert_equal [h1,h3,h4],@field.value
      assert_equal [h4],@field.delete_by_value("me")
      assert_equal [h4],@field.value
    end
    
    def test_index_get
      setup_an_array
      val = @test[2]
      assert_equal val,@field[2]
    end

    def test_index_set
      setup_an_array
      val = HashField.new("snigger","Snigger",{:key => "name"})
      @field[3] = val
      assert_equal val,@field.value[3]
      val1 = "a String"
      assert_raises(Jirarest2::ValueNotAllowedException) { @field[6] = val1 } # No field mixing allowed
    end
    
    def test_push
      @field << "Mikey"
      @field << "Minney"
      assert_raises(Jirarest2::ValueNotAllowedException) { @field << 42 }
      assert_equal ["Mikey", "Minney"],@field.value
    end
    
    def test_to_j
      ret = nil
      assert_equal ret, @field.to_j
      setup_an_array
      ret = {"customfield_10006"=>[{"name"=>"me"}, {"name"=>"minime"}, {"id"=>"me"}, {"id"=>"moooo"}]}
      assert_equal ret, @field.to_j
      @field.value = ["number1","number2","number3"]
      ret = {"customfield_10006"=>["number1", "number2", "number3"]}
      assert_equal ret, @field.to_j
      
    end
  end # class TestMultiField
  
  class TestCascadingField < TestField
    def setup
      @fieldid = "customfield_10000"
      @fieldname = "Cascading Select Test"
      @fieldtype = "CascadingField"
      @fieldargs = Hash.new
      @fieldrequired = true
      super
    end
    
    # This could be put to the top class but here it is anchored
    def test_fieldtype
      assert_instance_of Jirarest2Field::CascadingField, @field
    end
    
    def test_to_j
      ret = nil
      assert_equal ret,@field.to_j
    end
    
    def test_set_get_value
      assert_raises(Jirarest2::ValueNotAllowedException) { @field.value = "Lorem ipsum" }
      @field.value = ["Lorem","ipsum"]
      assert_equal ["Lorem", "ipsum"],@field.value
    end
    
    def test_allowed 
      @field.allowed_values= [{ "color" => ["red","green","yellow"],"car" => ["bmw","mini","mg","vw"], "lang" => ["ruby","Java","C","C#"]}]
      @field.value = ["color","red"]
      @field.value = ["car","mg"]
      assert_raises(Jirarest2::ValueNotAllowedException) { @field.value = ["color","lang"] }
      assert_raises(Jirarest2::ValueNotAllowedException) { @field.value = ["color"] }
      assert_raises(Jirarest2::ValueNotAllowedException) { @field.value = ["music"] }
      assert_raises(Jirarest2::ValueNotAllowedException) { @field.value = ["music","Cello"] }
    end
    
  end # class TestCascadingField
  
end # module

=begin
Shouldn't be used again. Is kept here just in case
def get_createmeta
  require "json"
  j = JSON.parse( IO.read("data/createmeta"))
  string = "# -*- coding: utf-8 -*-\n"
  string << "require \"minitest/autorun\"\n"
  string << "require \"jirarest2/field\"\n"
  string << "require \"json\"\n"
  string << "require \"deb\"\n\n"
  string << "# Extraclass to get all the different cases\n"
  string << "class TestFieldCreatemeta < MiniTest::Unit::TestCase\n\n"
  string << "=begin\n"
  j["projects"][0]["issuetypes"][0]["fields"].each{ |id,cont|
    string << "  def test_#{id}\n"
    string << "    fstruct = \{\"#{id}\" => #{cont}\}\n"
    string << "    ppp fstruct\n"
    string << "    field = Jirarest2Field::TODO.new(\"#{id}\",\"#{cont["name"]}\",{:required => false, :createmeta => fstruct[\"#{id}\"]})\n"
    string << "    ppp field\n"
    string << "    allowed_v = [] # TODO \n"
    string << "    assert_equal \"#{id}\", field.id\n"
    string << "    assert_equal \"#{cont["name"]}\", field.name\n"
    string << "    assert_equal false, field.readonly\n"
    string << "    assert_equal \"value\", field.key\n"
    string << "    assert_raises(NoMethodError) { field.key }\n"
    string << "    assert_equal allowed_v, field.allowed_values\n"
    string << "  end\n\n"
  }
  string << "=end\n"
  string << "end"
  File.open("test_fieldcreatemeta.rb", 'w') {|f| f.write(string) }
end
=end

