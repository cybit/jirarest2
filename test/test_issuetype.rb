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

end # class TestIssuetype

