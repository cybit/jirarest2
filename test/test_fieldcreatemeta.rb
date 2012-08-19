# -*- coding: utf-8 -*-
require "minitest/autorun"
require "jirarest2/field"
require "json"
require "deb"

# Extraclass to get all the different cases
class TestFieldCreatemeta < MiniTest::Unit::TestCase

  def test_summary
    fstruct = {"summary" => {"required"=>true, "schema"=>{"type"=>"string", "system"=>"summary"}, "name"=>"Summary", "operations"=>["set"]}}
    field = Jirarest2Field::TextField.new("summary","Summary",{:required => false, :createmeta => fstruct["summary"]})
    allowed_v = []
    assert_equal "summary", field.id
    assert_equal "Summary", field.name
    assert_equal false, field.readonly
    assert_raises(NoMethodError) { field.key }
    assert_equal allowed_v, field.allowed_values
  end

  def test_customfield_10307 # URL -> TextField
    fstruct = {"customfield_10307" => {"required"=>false, "schema"=>{"type"=>"string", "custom"=>"com.atlassian.jira.plugin.system.customfieldtypes:url", "customId"=>10307}, "name"=>"URL", "operations"=>["set"]}}
    field = Jirarest2Field::TextField.new("customfield_10307","URL",{:required => false, :createmeta => fstruct["customfield_10307"]})
    allowed_v = [] # TODO 
    assert_equal "customfield_10307", field.id
    assert_equal "URL", field.name
    assert_equal false, field.readonly
    assert_raises(NoMethodError) { field.key }
    assert_equal allowed_v, field.allowed_values
  end

  def test_timetracking # timetracking -> TextField
    fstruct = {"timetracking" => {"required"=>false, "schema"=>{"type"=>"timetracking", "system"=>"timetracking"}, "name"=>"Time Tracking", "operations"=>["set", "edit"]}}
    field = Jirarest2Field::TextField.new("timetracking","Time Tracking",{:required => false, :createmeta => fstruct["timetracking"]})
    allowed_v = []
    assert_equal "timetracking", field.id
    assert_equal "Time Tracking", field.name
    assert_equal false, field.readonly
    assert_raises(NoMethodError) { field.key }
    assert_equal allowed_v, field.allowed_values
  end

  def test_customfield_10306 # Version Picker -> VersionField
    fstruct = {"customfield_10306" => {"required"=>false, "schema"=>{"type"=>"version", "custom"=>"com.atlassian.jira.plugin.system.customfieldtypes:version", "customId"=>10306}, "name"=>"Single Version Picker Field", "operations"=>["set"], "allowedValues"=>[[{"self"=>"http://localhost:2990/jira/rest/api/2/version/10000", "id"=>"10000", "description"=>"Version 0.1 dooh", "name"=>"0.1", "archived"=>false, "released"=>false, "releaseDate"=>"2012-07-01"}, {"self"=>"http://localhost:2990/jira/rest/api/2/version/10001", "id"=>"10001", "description"=>"And now v0.2", "name"=>"0.2", "archived"=>false, "released"=>false, "releaseDate"=>"2012-08-01"}, {"self"=>"http://localhost:2990/jira/rest/api/2/version/10002", "id"=>"10002", "description"=>"Version 0.3", "name"=>"0.3", "archived"=>false, "released"=>false, "releaseDate"=>"2012-08-31"}]]}}
    field = Jirarest2Field::VersionField.new("customfield_10306","Single Version Picker Field",{:required => false, :createmeta => fstruct["customfield_10306"]})
    allowed_v = ["0.1", "0.2", "0.3"]
    assert_equal "customfield_10306", field.id
    assert_equal "Single Version Picker Field", field.name
    assert_equal false, field.readonly
    assert_equal "name", field.key
    assert_equal allowed_v, field.allowed_values
  end

  def test_customfield_10309 # hiddenjobswitch -> TextField
    fstruct = {"customfield_10309" => {"required"=>false, "schema"=>{"type"=>"string", "custom"=>"com.atlassian.jirafisheyeplugin:hiddenjobswitch", "customId"=>10309}, "name"=>"Job Switch (Hidden)", "operations"=>["set"]}}
    field = Jirarest2Field::TextField.new("customfield_10309","Job Switch (Hidden)",{:required => false, :createmeta => fstruct["customfield_10309"]})
    allowed_v = []
    assert_equal "customfield_10309", field.id
    assert_equal "Job Switch (Hidden)", field.name
    assert_equal false, field.readonly
    assert_raises(NoMethodError) { field.key }
    assert_equal allowed_v, field.allowed_values
  end

  def test_customfield_10308 # Multi Version Picker -> MultiVersionField
    fstruct = {"customfield_10308" => {"required"=>false, "schema"=>{"type"=>"array", "items"=>"version", "custom"=>"com.atlassian.jira.plugin.system.customfieldtypes:multiversion", "customId"=>10308}, "name"=>"Multi Version Picker", "operations"=>["set", "add", "remove"], "allowedValues"=>[[{"self"=>"http://localhost:2990/jira/rest/api/2/version/10000", "id"=>"10000", "description"=>"Version 0.1 dooh", "name"=>"0.1", "archived"=>false, "released"=>false, "releaseDate"=>"2012-07-01"}, {"self"=>"http://localhost:2990/jira/rest/api/2/version/10001", "id"=>"10001", "description"=>"And now v0.2", "name"=>"0.2", "archived"=>false, "released"=>false, "releaseDate"=>"2012-08-01"}, {"self"=>"http://localhost:2990/jira/rest/api/2/version/10002", "id"=>"10002", "description"=>"Version 0.3", "name"=>"0.3", "archived"=>false, "released"=>false, "releaseDate"=>"2012-08-31"}]]}}
    field = Jirarest2Field::MultiVersionField.new("customfield_10308","Multi Version Picker",{:required => false, :createmeta => fstruct["customfield_10308"]})
    allowed_v = ["0.1","0.2","0.3"]
    assert_equal "customfield_10308", field.id
    assert_equal "Multi Version Picker", field.name
    assert_equal false, field.readonly
    assert_equal "name", field.key
    assert_equal allowed_v, field.allowed_values
  end

  def test_issuetype # issuetype -> HashField
    fstruct = {"issuetype" => {"required"=>true, "schema"=>{"type"=>"issuetype", "system"=>"issuetype"}, "name"=>"Issue Type", "operations"=>[], "allowedValues"=>[{"self"=>"http://localhost:2990/jira/rest/api/2/issuetype/6", "id"=>"6", "description"=>"An own issue type", "iconUrl"=>"http://localhost:2990/jira/images/icons/ico_epic.png", "name"=>"My issue type", "subtask"=>false}]}}
    field = Jirarest2Field::HashField.new("issuetype","Issue Type",{:required => false, :createmeta => fstruct["issuetype"]})
    allowed_v = ["My issue type"]
    assert_equal "issuetype", field.id
    assert_equal "Issue Type", field.name
    assert_equal true, field.readonly
    assert_equal "name", field.key
    assert_equal allowed_v, field.allowed_values
  end

  def test_customfield_10303 # multigroupPicker -> MultiUserField
    fstruct = {"customfield_10303" => {"required"=>false, "schema"=>{"type"=>"array", "items"=>"group", "custom"=>"com.atlassian.jira.plugin.system.customfieldtypes:multigrouppicker", "customId"=>10303}, "name"=>"Multi Group", "operations"=>["add", "set", "remove"]}}
    field = Jirarest2Field::MultiUserField.new("customfield_10303","Multi Group",{:required => false, :createmeta => fstruct["customfield_10303"]})
    allowed_v = []
    assert_equal "customfield_10303", field.id
    assert_equal "Multi Group", field.name
    assert_equal false, field.readonly
    assert_equal "name", field.key
    assert_equal allowed_v, field.allowed_values
  end

  def test_customfield_10302 # importid -> NumberField
    fstruct = {"customfield_10302" => {"required"=>false, "schema"=>{"type"=>"number", "custom"=>"com.atlassian.jira.plugin.system.customfieldtypes:importid", "customId"=>10302}, "name"=>"Import ID Field range search", "operations"=>["set"]}}
    field = Jirarest2Field::NumberField.new("customfield_10302","Import ID Field range search",{:required => false, :createmeta => fstruct["customfield_10302"]})
    allowed_v = []
    assert_equal "customfield_10302", field.id
    assert_equal "Import ID Field range search", field.name
    assert_equal false, field.readonly
    assert_raises(NoMethodError) { field.key }
    assert_equal allowed_v, field.allowed_values
  end

  def test_customfield_10305 # readonlyfield -> TextField
    fstruct = {"customfield_10305" => {"required"=>false, "schema"=>{"type"=>"string", "custom"=>"com.atlassian.jira.plugin.system.customfieldtypes:readonlyfield", "customId"=>10305}, "name"=>"RO Text Field", "operations"=>["set"]}}
    field = Jirarest2Field::TextField.new("customfield_10305","RO Text Field",{:required => false, :createmeta => fstruct["customfield_10305"]})
    allowed_v = []
    assert_equal "customfield_10305", field.id
    assert_equal "RO Text Field", field.name
    assert_equal false, field.readonly
    assert_raises(NoMethodError) { field.key }
    assert_equal allowed_v, field.allowed_values
  end

  def test_customfield_10304 # project -> ProjectField
    fstruct = {"customfield_10304" => {"required"=>false, "schema"=>{"type"=>"project", "custom"=>"com.atlassian.jira.plugin.system.customfieldtypes:project", "customId"=>10304}, "name"=>"Project Picket Field", "operations"=>["set"], "allowedValues"=>[[{"self"=>"http://localhost:2990/jira/rest/api/2/project/MFTP", "id"=>"10000", "key"=>"MFTP", "name"=>"My first Test Project", "avatarUrls"=>{"16x16"=>"http://localhost:2990/jira/secure/projectavatar?size=small&pid=10000&avatarId=10011", "48x48"=>"http://localhost:2990/jira/secure/projectavatar?pid=10000&avatarId=10011"}}, {"self"=>"http://localhost:2990/jira/rest/api/2/project/SP", "id"=>"10100", "key"=>"SP", "name"=>"Second Project", "avatarUrls"=>{"16x16"=>"http://localhost:2990/jira/secure/projectavatar?size=small&pid=10100&avatarId=10011", "48x48"=>"http://localhost:2990/jira/secure/projectavatar?pid=10100&avatarId=10011"}}]]}}
    field = Jirarest2Field::ProjectField.new("customfield_10304","Project Picket Field",{:required => false, :createmeta => fstruct["customfield_10304"]})
    allowed_v = ["My first Test Project", "Second Project"] 
    assert_equal "customfield_10304", field.id
    assert_equal "Project Picket Field", field.name
    assert_equal false, field.readonly
    assert_equal "name", field.key
    assert_equal allowed_v, field.allowed_values
  end

  def test_resolution # resolution -> HashField
    fstruct = {"resolution" => {"required"=>false, "schema"=>{"type"=>"resolution", "system"=>"resolution"}, "name"=>"Resolution", "operations"=>["set"], "allowedValues"=>[{"self"=>"http://localhost:2990/jira/rest/api/2/resolution/1", "name"=>"Fixed", "id"=>"1"}, {"self"=>"http://localhost:2990/jira/rest/api/2/resolution/2", "name"=>"Won't Fix", "id"=>"2"}, {"self"=>"http://localhost:2990/jira/rest/api/2/resolution/3", "name"=>"Duplicate", "id"=>"3"}, {"self"=>"http://localhost:2990/jira/rest/api/2/resolution/4", "name"=>"Incomplete", "id"=>"4"}, {"self"=>"http://localhost:2990/jira/rest/api/2/resolution/5", "name"=>"Cannot Reproduce", "id"=>"5"}]}}
    field = Jirarest2Field::HashField.new("resolution","Resolution",{:required => false, :createmeta => fstruct["resolution"]})
    allowed_v = ["Fixed", "Won't Fix", "Duplicate", "Incomplete", "Cannot Reproduce"] 
    assert_equal "resolution", field.id
    assert_equal "Resolution", field.name
    assert_equal false, field.readonly
    assert_equal "name", field.key
    assert_equal allowed_v, field.allowed_values
  end

  def test_fixVersions # version -> MultiVersionField
    fstruct = {"fixVersions" => {"required"=>false, "schema"=>{"type"=>"array", "items"=>"version", "system"=>"fixVersions"}, "name"=>"Fix Version/s", "operations"=>["set", "add", "remove"], "allowedValues"=>[{"self"=>"http://localhost:2990/jira/rest/api/2/version/10000", "id"=>"10000", "description"=>"Version 0.1 dooh", "name"=>"0.1", "archived"=>false, "released"=>false, "releaseDate"=>"2012-07-01", "overdue"=>true, "userReleaseDate"=>"01/Jul/12"}, {"self"=>"http://localhost:2990/jira/rest/api/2/version/10001", "id"=>"10001", "description"=>"And now v0.2", "name"=>"0.2", "archived"=>false, "released"=>false, "releaseDate"=>"2012-08-01", "overdue"=>true, "userReleaseDate"=>"01/Aug/12"}, {"self"=>"http://localhost:2990/jira/rest/api/2/version/10002", "id"=>"10002", "description"=>"Version 0.3", "name"=>"0.3", "archived"=>false, "released"=>false, "releaseDate"=>"2012-08-31", "overdue"=>false, "userReleaseDate"=>"31/Aug/12"}]}}
    field = Jirarest2Field::MultiVersionField.new("fixVersions","Fix Version/s",{:required => false, :createmeta => fstruct["fixVersions"]})
    allowed_v = ["0.1","0.2","0.3"]
    assert_equal "fixVersions", field.id
    assert_equal "Fix Version/s", field.name
    assert_equal false, field.readonly
    assert_equal "name", field.key
    assert_equal allowed_v, field.allowed_values
  end

  def test_reporter # user -> UserField
    fstruct = {"reporter" => {"required"=>true, "schema"=>{"type"=>"user", "system"=>"reporter"}, "name"=>"Reporter", "autoCompleteUrl"=>"http://localhost:2990/jira/rest/api/latest/user/search?username=", "operations"=>["set"]}}
    field = Jirarest2Field::UserField.new("reporter","Reporter",{:required => false, :createmeta => fstruct["reporter"]})
    allowed_v = []
    assert_equal "reporter", field.id
    assert_equal "Reporter", field.name
    assert_equal false, field.readonly
    assert_equal "name", field.key
    assert_equal allowed_v, field.allowed_values
  end

  def test_description # description -> TextField
    fstruct = {"description" => {"required"=>false, "schema"=>{"type"=>"string", "system"=>"description"}, "name"=>"Description", "operations"=>["set"]}}
    field = Jirarest2Field::TextField.new("description","Description",{:required => false, :createmeta => fstruct["description"]})
    allowed_v = []
    assert_equal "description", field.id
    assert_equal "Description", field.name
    assert_equal false, field.readonly
    assert_raises(NoMethodError) { field.key }
    assert_equal allowed_v, field.allowed_values
  end

  def test_priority # priority -> HashField
    fstruct = {"priority" => {"required"=>false, "schema"=>{"type"=>"priority", "system"=>"priority"}, "name"=>"Priority", "operations"=>["set"], "allowedValues"=>[{"self"=>"http://localhost:2990/jira/rest/api/2/priority/1", "iconUrl"=>"http://localhost:2990/jira/images/icons/priority_blocker.gif", "name"=>"Blocker", "id"=>"1"}, {"self"=>"http://localhost:2990/jira/rest/api/2/priority/2", "iconUrl"=>"http://localhost:2990/jira/images/icons/priority_critical.gif", "name"=>"Critical", "id"=>"2"}, {"self"=>"http://localhost:2990/jira/rest/api/2/priority/3", "iconUrl"=>"http://localhost:2990/jira/images/icons/priority_major.gif", "name"=>"Major", "id"=>"3"}, {"self"=>"http://localhost:2990/jira/rest/api/2/priority/4", "iconUrl"=>"http://localhost:2990/jira/images/icons/priority_minor.gif", "name"=>"Minor", "id"=>"4"}, {"self"=>"http://localhost:2990/jira/rest/api/2/priority/5", "iconUrl"=>"http://localhost:2990/jira/images/icons/priority_trivial.gif", "name"=>"Trivial", "id"=>"5"}]}}
    field = Jirarest2Field::HashField.new("priority","Priority",{:required => false, :createmeta => fstruct["priority"]})
    allowed_v = ["Blocker", "Critical", "Major", "Minor", "Trivial"]
    assert_equal "priority", field.id
    assert_equal "Priority", field.name
    assert_equal false, field.readonly
    assert_equal "name", field.key
    assert_equal allowed_v, field.allowed_values
  end

  def test_customfield_10001 # datetime -> DateTimeField
    fstruct = {"customfield_10001" => {"required"=>false, "schema"=>{"type"=>"datetime", "custom"=>"com.atlassian.jira.plugin.system.customfieldtypes:datetime", "customId"=>10001}, "name"=>"Date Time Field", "operations"=>["set"]}}
    field = Jirarest2Field::DateTimeField.new("customfield_10001","Date Time Field",{:required => false, :createmeta => fstruct["customfield_10001"]})
    allowed_v = []
    assert_equal "customfield_10001", field.id
    assert_equal "Date Time Field", field.name
    assert_equal false, field.readonly
    assert_raises(NoMethodError) { field.key }
    assert_equal allowed_v, field.allowed_values
  end

  def test_duedate # date -> DateField
    fstruct = {"duedate" => {"required"=>false, "schema"=>{"type"=>"date", "system"=>"duedate"}, "name"=>"Due Date", "operations"=>["set"]}}
    field = Jirarest2Field::DateField.new("duedate","Due Date",{:required => false, :createmeta => fstruct["duedate"]})
    allowed_v = []
    assert_equal "duedate", field.id
    assert_equal "Due Date", field.name
    assert_equal false, field.readonly
    assert_raises(NoMethodError) { field.key }
    assert_equal allowed_v, field.allowed_values
  end

  def test_customfield_10002 # datepicker -> DateField
    fstruct = {"customfield_10002" => {"required"=>false, "schema"=>{"type"=>"date", "custom"=>"com.atlassian.jira.plugin.system.customfieldtypes:datepicker", "customId"=>10002}, "name"=>"Date Picker", "operations"=>["set"]}}
    field = Jirarest2Field::DateField.new("customfield_10002","Date Picker",{:required => false, :createmeta => fstruct["customfield_10002"]})
    allowed_v = []
    assert_equal "customfield_10002", field.id
    assert_equal "Date Picker", field.name
    assert_equal false, field.readonly
    assert_raises(NoMethodError) { field.key }
    assert_equal allowed_v, field.allowed_values
  end

  def test_customfield_10310 # jobcheckbox -> TextField
    fstruct = {"customfield_10310" => {"required"=>false, "schema"=>{"type"=>"string", "custom"=>"com.atlassian.jirafisheyeplugin:jobcheckbox", "customId"=>10310}, "name"=>"Job Checkbox", "operations"=>["set"]}}
    field = Jirarest2Field::TextField.new("customfield_10310","Job Checkbox",{:required => false, :createmeta => fstruct["customfield_10310"]})
    allowed_v = []
    assert_equal "customfield_10310", field.id
    assert_equal "Job Checkbox", field.name
    assert_equal false, field.readonly
    assert_raises(NoMethodError) { field.key }
    assert_equal allowed_v, field.allowed_values
  end

  def test_customfield_10003 # textarea -> TextField
    fstruct = {"customfield_10003" => {"required"=>false, "schema"=>{"type"=>"string", "custom"=>"com.atlassian.jira.plugin.system.customfieldtypes:textarea", "customId"=>10003}, "name"=>"Großes Text", "operations"=>["set"]}}
    field = Jirarest2Field::TextField.new("customfield_10003","Großes Text",{:required => false, :createmeta => fstruct["customfield_10003"]})
    allowed_v = []
    assert_equal "customfield_10003", field.id
    assert_equal "Großes Text", field.name
    assert_equal false, field.readonly
    assert_raises(NoMethodError) { field.key }
    assert_equal allowed_v, field.allowed_values
  end

  def test_customfield_10311 # float -> NumberField
    fstruct = {"customfield_10311" => {"required"=>false, "schema"=>{"type"=>"number", "custom"=>"com.atlassian.jira.plugin.system.customfieldtypes:float", "customId"=>10311}, "name"=>"Numbers no", "operations"=>["set"]}}
    field = Jirarest2Field::NumberField.new("customfield_10311","Numbers no",{:required => false, :createmeta => fstruct["customfield_10311"]})
    allowed_v = []
    assert_equal "customfield_10311", field.id
    assert_equal "Numbers no", field.name
    assert_equal false, field.readonly
    assert_raises(NoMethodError) { field.key }
    assert_equal allowed_v, field.allowed_values
  end

  def test_customfield_10004 # multicheckboxes -> MultiHashField
    fstruct = {"customfield_10004" => {"required"=>false, "schema"=>{"type"=>"array", "items"=>"string", "custom"=>"com.atlassian.jira.plugin.system.customfieldtypes:multicheckboxes", "customId"=>10004}, "name"=>"Multi Checkboxes", "operations"=>["add", "set", "remove"], "allowedValues"=>[{"self"=>"http://localhost:2990/jira/rest/api/2/customFieldOption/10019", "value"=>"Göthe", "id"=>"10019"}, {"self"=>"http://localhost:2990/jira/rest/api/2/customFieldOption/10020", "value"=>"Schiller", "id"=>"10020"}, {"self"=>"http://localhost:2990/jira/rest/api/2/customFieldOption/10021", "value"=>"Heine", "id"=>"10021"}, {"self"=>"http://localhost:2990/jira/rest/api/2/customFieldOption/10022", "value"=>"Kafka", "id"=>"10022"}]}}
    field = Jirarest2Field::MultiHashField.new("customfield_10004","Multi Checkboxes",{:required => false, :createmeta => fstruct["customfield_10004"]})
    allowed_v = ["Göthe", "Schiller", "Heine", "Kafka"]
    assert_equal "customfield_10004", field.id
    assert_equal "Multi Checkboxes", field.name
    assert_equal false, field.readonly
    assert_equal "value", field.key
    assert_equal allowed_v, field.allowed_values
  end

  def test_customfield_10312 # float -> NumberField
    fstruct = {"customfield_10312" => {"required"=>false, "schema"=>{"type"=>"number", "custom"=>"com.atlassian.jira.plugin.system.customfieldtypes:float", "customId"=>10312}, "name"=>"Numbers range", "operations"=>["set"]}}
    field = Jirarest2Field::NumberField.new("customfield_10312","Numbers range",{:required => false, :createmeta => fstruct["customfield_10312"]})
    allowed_v = []
    assert_equal "customfield_10312", field.id
    assert_equal "Numbers range", field.name
    assert_equal false, field.readonly
    assert_raises(NoMethodError) { field.key }
    assert_equal allowed_v, field.allowed_values
  end

  def test_customfield_10000 # cascadingselect -> CascadingField
    fstruct = {"customfield_10000" => {"required"=>false, "schema"=>{"type"=>"array", "items"=>"string", "custom"=>"com.atlassian.jira.plugin.system.customfieldtypes:cascadingselect", "customId"=>10000}, "name"=>"Cascading Select Test", "operations"=>["set"], "allowedValues"=>[{"self"=>"http://localhost:2990/jira/rest/api/2/customFieldOption/10000", "value"=>"English", "id"=>"10000", "children"=>[{"self"=>"http://localhost:2990/jira/rest/api/2/customFieldOption/10003", "value"=>"One", "id"=>"10003"}, {"self"=>"http://localhost:2990/jira/rest/api/2/customFieldOption/10004", "value"=>"Two", "id"=>"10004"}, {"self"=>"http://localhost:2990/jira/rest/api/2/customFieldOption/10005", "value"=>"Three", "id"=>"10005"}, {"self"=>"http://localhost:2990/jira/rest/api/2/customFieldOption/10006", "value"=>"Four", "id"=>"10006"}]}, {"self"=>"http://localhost:2990/jira/rest/api/2/customFieldOption/10001", "value"=>"German", "id"=>"10001", "children"=>[{"self"=>"http://localhost:2990/jira/rest/api/2/customFieldOption/10007", "value"=>"Eins", "id"=>"10007"}, {"self"=>"http://localhost:2990/jira/rest/api/2/customFieldOption/10008", "value"=>"zwei", "id"=>"10008"}, {"self"=>"http://localhost:2990/jira/rest/api/2/customFieldOption/10009", "value"=>"drEi", "id"=>"10009"}, {"self"=>"http://localhost:2990/jira/rest/api/2/customFieldOption/10010", "value"=>"vier", "id"=>"10010"}]}, {"self"=>"http://localhost:2990/jira/rest/api/2/customFieldOption/10002", "value"=>"ISO", "id"=>"10002", "children"=>[{"self"=>"http://localhost:2990/jira/rest/api/2/customFieldOption/10011", "value"=>"Unaone", "id"=>"10011"}, {"self"=>"http://localhost:2990/jira/rest/api/2/customFieldOption/10012", "value"=>"Bissotwo", "id"=>"10012"}, {"self"=>"http://localhost:2990/jira/rest/api/2/customFieldOption/10013", "value"=>"Terrathree", "id"=>"10013"}, {"self"=>"http://localhost:2990/jira/rest/api/2/customFieldOption/10014", "value"=>"Kartefour", "id"=>"10014"}]}]}}
    field = Jirarest2Field::CascadingField.new("customfield_10000","Cascading Select Test",{:required => false, :createmeta => fstruct["customfield_10000"]})
    allowed_v = [{"English"=>["One", "Two", "Three", "Four"]}, {"German"=>["Eins", "zwei", "drEi", "vier"]}, {"ISO"=>["Unaone", "Bissotwo", "Terrathree", "Kartefour"]}]
    assert_equal "customfield_10000", field.id
    assert_equal "Cascading Select Test", field.name
    assert_equal false, field.readonly
    assert_equal "value", field.key
    assert_equal allowed_v, field.allowed_values
  end

  def test_customfield_10102 # textfield -> TextField
    fstruct = {"customfield_10102" => {"required"=>false, "schema"=>{"type"=>"string", "custom"=>"com.atlassian.jira.plugin.system.customfieldtypes:textfield", "customId"=>10102}, "name"=>"projects", "operations"=>["set"]}}
    field = Jirarest2Field::TextField.new("customfield_10102","projects",{:required => false, :createmeta => fstruct["customfield_10102"]})
    allowed_v = []
    assert_equal "customfield_10102", field.id
    assert_equal "projects", field.name
    assert_equal false, field.readonly
    assert_raises(NoMethodError) { field.key }
    assert_equal allowed_v, field.allowed_values
  end

  def test_customfield_10101 # textfield -> TextField
    fstruct = {"customfield_10101" => {"required"=>false, "schema"=>{"type"=>"string", "custom"=>"com.atlassian.jira.plugin.system.customfieldtypes:textfield", "customId"=>10101}, "name"=>"Issue Type", "operations"=>["set"]}}
    field = Jirarest2Field::TextField.new("customfield_10101","Issue Type",{:required => false, :createmeta => fstruct["customfield_10101"]})
    allowed_v = []
    assert_equal "customfield_10101", field.id
    assert_equal "Issue Type", field.name
    assert_equal false, field.readonly
    assert_raises(NoMethodError) { field.key }
    assert_equal allowed_v, field.allowed_values
  end

  def test_customfield_10100 # textfield -> TextField
    fstruct = {"customfield_10100" => {"required"=>false, "schema"=>{"type"=>"string", "custom"=>"com.atlassian.jira.plugin.system.customfieldtypes:textfield", "customId"=>10100}, "name"=>"issuetype", "operations"=>["set"]}}
    field = Jirarest2Field::TextField.new("customfield_10100","issuetype",{:required => false, :createmeta => fstruct["customfield_10100"]})
    allowed_v = [] 
    assert_equal "customfield_10100", field.id
    assert_equal "issuetype", field.name
    assert_equal false, field.readonly
    assert_raises(NoMethodError) { field.key }
    assert_equal allowed_v, field.allowed_values
  end

  def test_customfield_10006 # select -> HashField
    fstruct = {"customfield_10006" => {"required"=>false, "schema"=>{"type"=>"string", "custom"=>"com.atlassian.jira.plugin.system.customfieldtypes:select", "customId"=>10006}, "name"=>"List select", "operations"=>["set"], "allowedValues"=>[{"self"=>"http://localhost:2990/jira/rest/api/2/customFieldOption/10015", "value"=>"Räuber", "id"=>"10015"}, {"self"=>"http://localhost:2990/jira/rest/api/2/customFieldOption/10016", "value"=>"Kabale und Liebe", "id"=>"10016"}, {"self"=>"http://localhost:2990/jira/rest/api/2/customFieldOption/10017", "value"=>"Faust", "id"=>"10017"}, {"self"=>"http://localhost:2990/jira/rest/api/2/customFieldOption/10018", "value"=>"Landleben", "id"=>"10018"}]}}
    field = Jirarest2Field::HashField.new("customfield_10006","List select",{:required => false, :createmeta => fstruct["customfield_10006"]})
    allowed_v = ["Räuber", "Kabale und Liebe", "Faust", "Landleben"]
    assert_equal "customfield_10006", field.id
    assert_equal "List select", field.name
    assert_equal false, field.readonly
    assert_equal "value", field.key
    assert_equal allowed_v, field.allowed_values
  end

  def test_customfield_10005 # multiselect -> MultiHashField
    fstruct = {"customfield_10005" => {"required"=>false, "schema"=>{"type"=>"array", "items"=>"string", "custom"=>"com.atlassian.jira.plugin.system.customfieldtypes:multiselect", "customId"=>10005}, "name"=>"Multi Select", "operations"=>["add", "set", "remove"], "allowedValues"=>[{"self"=>"http://localhost:2990/jira/rest/api/2/customFieldOption/10023", "value"=>"Glocke", "id"=>"10023"}, {"self"=>"http://localhost:2990/jira/rest/api/2/customFieldOption/10024", "value"=>"Kabale und Liebe", "id"=>"10024"}, {"self"=>"http://localhost:2990/jira/rest/api/2/customFieldOption/10025", "value"=>"Schiller", "id"=>"10025"}, {"self"=>"http://localhost:2990/jira/rest/api/2/customFieldOption/10026", "value"=>"Göthe", "id"=>"10026"}, {"self"=>"http://localhost:2990/jira/rest/api/2/customFieldOption/10027", "value"=>"Faust", "id"=>"10027"}]}}
    field = Jirarest2Field::MultiHashField.new("customfield_10005","Multi Select",{:required => false, :createmeta => fstruct["customfield_10005"]})
    allowed_v = ["Glocke", "Kabale und Liebe", "Schiller", "Göthe", "Faust"]
    assert_equal "customfield_10005", field.id
    assert_equal "Multi Select", field.name
    assert_equal false, field.readonly
    assert_equal "value", field.key
    assert_equal allowed_v, field.allowed_values
  end

  def test_labels # labels -> MultiStringField
    fstruct = {"labels" => {"required"=>false, "schema"=>{"type"=>"array", "items"=>"string", "system"=>"labels"}, "name"=>"Labels", "autoCompleteUrl"=>"http://localhost:2990/jira/rest/api/1.0/labels/suggest?query=", "operations"=>["add", "set", "remove"]}}
    field = Jirarest2Field::MultiStringField.new("labels","Labels",{:required => false, :createmeta => fstruct["labels"]})
    allowed_v = []
    assert_equal "labels", field.id
    assert_equal "Labels", field.name
    assert_equal false, field.readonly
    assert_raises(NoMethodError) { field.key }
    assert_equal allowed_v, field.allowed_values
  end

  def test_customfield_10315 # userPicker -> UserField
    fstruct = {"customfield_10315" => {"required"=>false, "schema"=>{"type"=>"user", "custom"=>"com.atlassian.jira.plugin.system.customfieldtypes:userpicker", "customId"=>10315}, "name"=>"User Picker User", "autoCompleteUrl"=>"http://localhost:2990/jira/rest/api/1.0/users/picker?fieldName=customfield_10315&query=", "operations"=>["set"]}}
    field = Jirarest2Field::UserField.new("customfield_10315","User Picker User",{:required => false, :createmeta => fstruct["customfield_10315"]})
    allowed_v = []
    assert_equal "customfield_10315", field.id
    assert_equal "User Picker User", field.name
    assert_equal false, field.readonly
    assert_equal "name", field.key
    assert_equal allowed_v, field.allowed_values
  end

  def test_assignee # assignee -> UserField
    fstruct = {"assignee" => {"required"=>false, "schema"=>{"type"=>"user", "system"=>"assignee"}, "name"=>"Assignee", "autoCompleteUrl"=>"http://localhost:2990/jira/rest/api/latest/user/assignable/search?issueKey=null&username=", "operations"=>["set"]}}
    field = Jirarest2Field::UserField.new("assignee","Assignee",{:required => false, :createmeta => fstruct["assignee"]})
    allowed_v = []
    assert_equal "assignee", field.id
    assert_equal "Assignee", field.name
    assert_equal false, field.readonly
    assert_equal "name", field.key
    assert_equal allowed_v, field.allowed_values
  end

  def test_customfield_10316 # userpicker -> UserField
    fstruct = {"customfield_10316" => {"required"=>false, "schema"=>{"type"=>"user", "custom"=>"com.atlassian.jira.plugin.system.customfieldtypes:userpicker", "customId"=>10316}, "name"=>"User Picker U+G", "autoCompleteUrl"=>"http://localhost:2990/jira/rest/api/1.0/users/picker?fieldName=customfield_10316&query=", "operations"=>["set"]}}
    field = Jirarest2Field::UserField.new("customfield_10316","User Picker U+G",{:required => false, :createmeta => fstruct["customfield_10316"]})
    allowed_v = []
    assert_equal "customfield_10316", field.id
    assert_equal "User Picker U+G", field.name
    assert_equal false, field.readonly
    assert_equal "name", field.key
    assert_equal allowed_v, field.allowed_values
  end

  def test_customfield_10313 # radiobuttons -> HashField
    fstruct = {"customfield_10313" => {"required"=>false, "schema"=>{"type"=>"string", "custom"=>"com.atlassian.jira.plugin.system.customfieldtypes:radiobuttons", "customId"=>10313}, "name"=>"Radios", "operations"=>["set"], "allowedValues"=>[{"self"=>"http://localhost:2990/jira/rest/api/2/customFieldOption/10100", "value"=>"Books", "id"=>"10100"}, {"self"=>"http://localhost:2990/jira/rest/api/2/customFieldOption/10101", "value"=>"EBooks", "id"=>"10101"}, {"self"=>"http://localhost:2990/jira/rest/api/2/customFieldOption/10102", "value"=>"Newspaper", "id"=>"10102"}, {"self"=>"http://localhost:2990/jira/rest/api/2/customFieldOption/10103", "value"=>"Websites", "id"=>"10103"}, {"self"=>"http://localhost:2990/jira/rest/api/2/customFieldOption/10104", "value"=>"Magazines", "id"=>"10104"}]}}
    field = Jirarest2Field::HashField.new("customfield_10313","Radios",{:required => false, :createmeta => fstruct["customfield_10313"]})
    allowed_v = ["Books", "EBooks", "Newspaper", "Websites", "Magazines"]
    assert_equal "customfield_10313", field.id
    assert_equal "Radios", field.name
    assert_equal false, field.readonly
    assert_equal "value", field.key
    assert_equal allowed_v, field.allowed_values
  end

  def test_customfield_10314 # select -> HashField
    fstruct = {"customfield_10314" => {"required"=>false, "schema"=>{"type"=>"string", "custom"=>"com.atlassian.jira.plugin.system.customfieldtypes:select", "customId"=>10314}, "name"=>"Select List Multi", "operations"=>["set"], "allowedValues"=>[{"self"=>"http://localhost:2990/jira/rest/api/2/customFieldOption/10105", "value"=>"Car", "id"=>"10105"}, {"self"=>"http://localhost:2990/jira/rest/api/2/customFieldOption/10106", "value"=>"Train", "id"=>"10106"}, {"self"=>"http://localhost:2990/jira/rest/api/2/customFieldOption/10107", "value"=>"Subway", "id"=>"10107"}, {"self"=>"http://localhost:2990/jira/rest/api/2/customFieldOption/10108", "value"=>"Underground", "id"=>"10108"}, {"self"=>"http://localhost:2990/jira/rest/api/2/customFieldOption/10109", "value"=>"Plane", "id"=>"10109"}, {"self"=>"http://localhost:2990/jira/rest/api/2/customFieldOption/10110", "value"=>"Ship", "id"=>"10110"}, {"self"=>"http://localhost:2990/jira/rest/api/2/customFieldOption/10111", "value"=>"Hovercraft", "id"=>"10111"}, {"self"=>"http://localhost:2990/jira/rest/api/2/customFieldOption/10112", "value"=>"Foot", "id"=>"10112"}]}}
    field = Jirarest2Field::HashField.new("customfield_10314","Select List Multi",{:required => false, :createmeta => fstruct["customfield_10314"]})
    allowed_v = ["Car", "Train", "Subway", "Underground", "Plane", "Ship", "Hovercraft", "Foot"]
    assert_equal "customfield_10314", field.id
    assert_equal "Select List Multi", field.name
    assert_equal false, field.readonly
    assert_equal "value", field.key
    assert_equal allowed_v, field.allowed_values
  end

  def test_attachment # attachment -> TextField
    fstruct = {"attachment" => {"required"=>false, "schema"=>{"type"=>"array", "items"=>"attachment", "system"=>"attachment"}, "name"=>"Attachment", "operations"=>[]}}
    field = Jirarest2Field::MultiStringField.new("attachment","Attachment",{:required => false, :createmeta => fstruct["attachment"]})
    allowed_v = []
    assert_equal "attachment", field.id
    assert_equal "Attachment", field.name
    assert_equal true, field.readonly
    assert_raises(NoMethodError) { field.key }
    assert_equal allowed_v, field.allowed_values
  end

  def test_customfield_10200 #multiuserpicker -> MultiUserField
    fstruct = {"customfield_10200" => {"required"=>false, "schema"=>{"type"=>"array", "items"=>"user", "custom"=>"com.atlassian.jira.plugin.system.customfieldtypes:multiuserpicker", "customId"=>10200}, "name"=>"Multi User", "autoCompleteUrl"=>"http://localhost:2990/jira/rest/api/1.0/users/picker?fieldName=customfield_10200&query=", "operations"=>["add", "set", "remove"]}}
    field = Jirarest2Field::MultiUserField.new("customfield_10200","Multi User",{:required => false, :createmeta => fstruct["customfield_10200"]})
    allowed_v = []
    assert_equal "customfield_10200", field.id
    assert_equal "Multi User", field.name
    assert_equal false, field.readonly
    assert_equal "name", field.key
    assert_equal allowed_v, field.allowed_values
  end

  def test_project # project -> ProjectField
    fstruct = {"project" => {"required"=>true, "schema"=>{"type"=>"project", "system"=>"project"}, "autoCompleteUrl"=>"Project", "operations"=>["set"], "allowedValues"=>[{"self"=>"http://localhost:2990/jira/rest/api/2/project/MFTP", "id"=>"10000", "key"=>"MFTP", "name"=>"My first Test Project", "avatarUrls"=>{"16x16"=>"http://localhost:2990/jira/secure/projectavatar?size=small&pid=10000&avatarId=10011", "48x48"=>"http://localhost:2990/jira/secure/projectavatar?pid=10000&avatarId=10011"}}]}}
    field = Jirarest2Field::ProjectField.new("project","",{:required => false, :createmeta => fstruct["project"]})
    allowed_v = ["My first Test Project"] # TODO 
    assert_equal "project", field.id
    assert_equal "", field.name
    assert_equal false, field.readonly
    assert_equal "name", field.key
    assert_equal allowed_v, field.allowed_values
  end

  def test_versions # version -> MultiVersionField
    fstruct = {"versions" => {"required"=>false, "schema"=>{"type"=>"array", "items"=>"version", "system"=>"versions"}, "name"=>"Affects Version/s", "operations"=>["set", "add", "remove"], "allowedValues"=>[{"self"=>"http://localhost:2990/jira/rest/api/2/version/10000", "id"=>"10000", "description"=>"Version 0.1 dooh", "name"=>"0.1", "archived"=>false, "released"=>false, "releaseDate"=>"2012-07-01", "overdue"=>true, "userReleaseDate"=>"01/Jul/12"}, {"self"=>"http://localhost:2990/jira/rest/api/2/version/10001", "id"=>"10001", "description"=>"And now v0.2", "name"=>"0.2", "archived"=>false, "released"=>false, "releaseDate"=>"2012-08-01", "overdue"=>true, "userReleaseDate"=>"01/Aug/12"}, {"self"=>"http://localhost:2990/jira/rest/api/2/version/10002", "id"=>"10002", "description"=>"Version 0.3", "name"=>"0.3", "archived"=>false, "released"=>false, "releaseDate"=>"2012-08-31", "overdue"=>false, "userReleaseDate"=>"31/Aug/12"}]}}
    field = Jirarest2Field::MultiVersionField.new("versions","Affects Version/s",{:required => false, :createmeta => fstruct["versions"]})
    allowed_v = ["0.1","0.2","0.3"]
    assert_equal "versions", field.id
    assert_equal "Affects Version/s", field.name
    assert_equal false, field.readonly
    assert_equal "name", field.key
    assert_equal allowed_v, field.allowed_values
  end

  def test_environment #environment -> TextField
    fstruct = {"environment" => {"required"=>false, "schema"=>{"type"=>"string", "system"=>"environment"}, "name"=>"Environment", "operations"=>["set"]}}
    field = Jirarest2Field::TextField.new("environment","Environment",{:required => false, :createmeta => fstruct["environment"]})
    allowed_v = []
    assert_equal "environment", field.id
    assert_equal "Environment", field.name
    assert_equal false, field.readonly
    assert_raises(NoMethodError) { field.key }
    assert_equal allowed_v, field.allowed_values
  end

  def test_customfield_10300 # grouppicker -> UserField
    fstruct = {"customfield_10300" => {"required"=>false, "schema"=>{"type"=>"group", "custom"=>"com.atlassian.jira.plugin.system.customfieldtypes:grouppicker", "customId"=>10300}, "name"=>"Pick Group", "operations"=>["set"]}}
    field = Jirarest2Field::UserField.new("customfield_10300","Pick Group",{:required => false, :createmeta => fstruct["customfield_10300"]})
    allowed_v = []
    assert_equal "customfield_10300", field.id
    assert_equal "Pick Group", field.name
    assert_equal false, field.readonly
    assert_equal "name", field.key
    assert_equal allowed_v, field.allowed_values
  end

  def test_customfield_10301 # importid -> NumberField
    fstruct = {"customfield_10301" => {"required"=>false, "schema"=>{"type"=>"number", "custom"=>"com.atlassian.jira.plugin.system.customfieldtypes:importid", "customId"=>10301}, "name"=>"Import ID Field no search", "operations"=>["set"]}}
    field = Jirarest2Field::NumberField.new("customfield_10301","Import ID Field no search",{:required => false, :createmeta => fstruct["customfield_10301"]})
    allowed_v = []
    assert_equal "customfield_10301", field.id
    assert_equal "Import ID Field no search", field.name
    assert_equal false, field.readonly
    assert_raises(NoMethodError) { field.key }
    assert_equal allowed_v, field.allowed_values
  end

  def test_components # components -> MultiHashField
    fstruct = {"components" => {"required"=>false, "schema"=>{"type"=>"array", "items"=>"component", "system"=>"components"}, "name"=>"Component/s", "operations"=>["add", "set", "remove"], "allowedValues"=>[{"self"=>"http://localhost:2990/jira/rest/api/2/component/10000", "id"=>"10000", "name"=>"Signal1", "description"=>"A component "}, {"self"=>"http://localhost:2990/jira/rest/api/2/component/10001", "id"=>"10001", "name"=>"Sissi", "description"=>"Another Component"}]}}
    field = Jirarest2Field::MultiHashField.new("components","Component/s",{:required => false, :createmeta => fstruct["components"]})
    allowed_v = ["Signal1","Sissi"]
    assert_equal "components", field.id
    assert_equal "Component/s", field.name
    assert_equal false, field.readonly
    assert_equal "name", field.key
    assert_equal allowed_v, field.allowed_values
  end

end
