require "minitest/autorun"
require "jirarest2/issuetype"
require "json"
require "deb"

class TestIssuetype < MiniTest::Unit::TestCase

  def setup
    @createmeta = JSON.parse(IO.read(File.dirname(__FILE__) + "/data/createmeta"))
    @issue = Issuetype.new
  end

  def test_createmeta
    #ppp @createmeta
    #    ppp @createmeta["projects"][0]["issuetypes"][0]
    @issue.createmeta(@createmeta["projects"][0]["issuetypes"][0])
    assert_equal "My issue type", @issue.name
    assert_equal "An own issue type",@issue.description
    assert_equal "summary",@issue.required_fields[0].id
    assert_equal "issuetype",@issue.required_fields[1].id
    assert_equal "reporter",@issue.required_fields[2].id
    assert_equal "project",@issue.required_fields[3].id
    assert_equal 4, @issue.required_fields.size
    assert_equal 44, @issue.fields.size
    # Some order as in test_fieldcreatemeta.rb
    fieldtypes = ["TextField", "TextField", "TimetrackingField", "VersionField", "TextField", "MultiVersionField", "HashField", "MultiUserField", "NumberField", "TextField", "ProjectField", "HashField", "MultiVersionField", "UserField", "TextField", "HashField", "DateTimeField", "DateField", "DateField", "TextField", "TextField", "NumberField", "MultiHashField", "NumberField", "CascadingField", "TextField", "TextField", "TextField", "HashField", "MultiHashField", "MultiStringField", "UserField", "UserField", "UserField", "HashField", "HashField", "MultiStringField", "MultiUserField", "ProjectField", "MultiVersionField", "TextField", "UserField", "NumberField", "MultiHashField"]
    (0..@issue.fields.size-1).each{ |i|
      assert_equal "Jirarest2Field::"+fieldtypes[i], @issue.fields.values[i].class.to_s
    }
  end
  
  def test_set_value
    @issue.createmeta(@createmeta["projects"][0]["issuetypes"][0])
    @issue.set_value("summary","blablabla")
    assert_equal "blablabla", @issue.fields["summary"].value 
    @issue.set_value("Summary","blablabla1")
    assert_equal "blablabla1", @issue.fields["summary"].value 
    @issue.set_value("summary","blablabla2",:id)
    assert_equal "blablabla2", @issue.fields["summary"].value 
    @issue.set_value("Summary","blablabla3",:name)
    assert_equal "blablabla3", @issue.fields["summary"].value 
    assert_raises(Jirarest2::WrongFieldnameException) { @issue.set_value("summary-wrong","blablabla") }
  end
  
  def test_get_value
    @issue.createmeta(@createmeta["projects"][0]["issuetypes"][0])
    @issue.fields["summary"].value = "blues"
    assert_equal "blues", @issue.get_value("Summary")
    assert_equal "blues", @issue.get_value("summary")
    assert_equal "blues", @issue.get_value("Summary",:name)
    assert_equal "blues", @issue.get_value("summary",:id)
    assert_raises(Jirarest2::WrongFieldnameException) { @issue.get_value("summary-wrong") }
  end

  def test_required_by_name
    @issue.createmeta(@createmeta["projects"][0]["issuetypes"][0])
    assert_equal ["Summary"], @issue.required_by_name(true)
    @issue.fields["summary"].value = "Let us fill it with something usefull"
    assert_equal ["Summary"], @issue.required_by_name
    assert_equal [], @issue.required_by_name(true)
  end
  
  def test_new_ticket_hash
    start = {"self"=>"http://localhost:2990/jira/rest/api/2/issuetype/6", "id" => "6", "description" => "An own issue type", "iconUrl" => "http://localhost:2990/jira/images/icons/ico_epic.png", "name" => "My issue type", "subtask" => false, "expand" => "fields", "fields" => {"summary" => {"required"=>true, "schema"=>{"type" => "string", "system" => "summary"}, "name" => "Summary", "operations" => ["set"]}, "customfield_10307" => {"required" => false, "schema" => {"type" => "string", "custom" => "com.atlassian.jira.plugin.system.customfieldtypes:url", "customId" => 10307}, "name" => "URL", "operations" => ["set"]}}}
    @issue.createmeta(start)
    @issue.createmeta(@createmeta["projects"][0]["issuetypes"][0])
    @issue.fields["summary"].value = "Let us fill it with something usefull"
    val = {"fields" => {"summary" => "Let us fill it with something usefull", "issuetype" => {"name" => "My issue type"}, "project" => {"key" => "MFTP"}}}
    assert_equal val, @issue.new_ticket_hash
    
  end

end # class TestIssuetype

