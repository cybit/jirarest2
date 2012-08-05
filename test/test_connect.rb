require "minitest/autorun"
require "jirarest2/connect"
require "jirarest2/password_credentials"
require "jirarest2/cookie_credentials"
require "webmock/minitest"

class TestConnect < MiniTest::Unit::TestCase
  def setup
    cred = PasswordCredentials.new("http://localhost:2990/jira/rest/api/2/","test","1234")
    @con = Connect.new(cred)
  end
  
  def test_access
    stub_request(:any,"http://localhost:2990/jira/rest/api/2/").with(:headers => {"Content-Type:" => "application/json;charset=UTF-8"})
  end

  def test_executeGET    
    stub_request(:get, "http://test:1234@localhost:2990/jira/rest/api/2/issue/createmeta/").with(:headers => {'Accept'=>'*/*', 'Content-Type'=>'application/json;charset=UTF-8', 'User-Agent'=>'Ruby'}).to_return(:status => 200, :body => '{"expand":"projects"}', :headers => {})
    assert_equal "projects", @con.execute("Get","issue/createmeta/","").result["expand"]
  end
  
  def test_executePOST
    stub_request(:post, "http://test:1234@localhost:2990/jira/rest/api/2/search/").with(:body => "{\"jql\":\"project = MFTP\",\"startAt\":0,\"maxResults\":4}",:headers => {'Accept'=>'*/*', 'Content-Type'=>'application/json;charset=UTF-8', 'User-Agent'=>'Ruby'}).to_return(:status => 200, :body => '{"expand":"schema,names","startAt":0,"maxResults":4,"total":9,"issues":[{"expand":"editmeta,renderedFields,transitions,changelog,operations","id":"10102","self":"http://localhost:2990/jira/rest/api/2/issue/10102","key":"MFTP-9","fields":{"summary":"AnotherissueatSunJul1516","progress":{"progress":0,"total":0}}}]}', :headers => {})

    query={"jql"=>"project = MFTP", "startAt"=>0, "maxResults"=>4 }
    assert_equal 4, @con.execute("Post","search/",query).result["maxResults"]
  end

  def test_check_uri_true
    stub_request(:get, "http://test:1234@localhost:2990/jira/rest/api/2/dashboard").with(:headers => {'Accept'=>'*/*', 'Content-Type'=>'application/json;charset=UTF-8', 'User-Agent'=>'Ruby'}).to_return(:status => 200, :body => "", :headers => {})
    assert_equal true,@con.check_uri
  end
  
  def test_check_uri_false
    stub_request(:get, "http://test:1234@localhost:2990/rest/api/2/dashboard").with(:headers => {'Accept'=>'*/*', 'Content-Type'=>'application/json;charset=UTF-8', 'User-Agent'=>'Ruby'}).to_return(:status => 400, :body => "", :headers => {})
    cred = PasswordCredentials.new("http://localhost:2990/rest/api/2/","test","1234")
    con1 = Connect.new(cred)
    assert_equal false,con1.check_uri
  end
  
  def test_heal_uri
    stub_request(:get, "http://test:1234@localhost:2990/jira/rest/api/2/dashboard").with(:headers => {'Accept'=>'*/*', 'Content-Type'=>'application/json;charset=UTF-8', 'User-Agent'=>'Ruby'}).to_return(:status => 200, :body => "", :headers => {})

    cred = PasswordCredentials.new("http://localhost:2990/jira//rest/api//2//","test","1234")
    con = Connect.new(cred)
    assert_equal "http://localhost:2990/jira/rest/api/2/",con.heal_uri
    assert_equal "http://localhost:2990/jira/rest/api/2/",con.heal_uri("http://localhost:2990/jira/rest/api/2/rest/api/2/")
    assert_equal "http://localhost:2990/jira/rest/api/2/",con.heal_uri("http://localhost:2990/jira/secure/Dashboard.jspa/rest/api/2/")
    assert_equal "http://localhost:2990/rest/api/2/",con.heal_uri("http://localhost:2990/secure/Dashboard.jspa/rest/api/2/")
    assert_equal "http://localhost:2990/jira/rest/api/2/",con.heal_uri("http://localhost:2990/jira/login.jsp/rest/api/2/")
    assert_equal "http://localhost:2990/rest/api/2/",con.heal_uri("http://localhost:2990/login.jsp/rest/api/2/")
    assert_equal "http://localhost/rest/api/2/",con.heal_uri("http://localhost/login.jsp/rest/api/2")
    assert_equal "http://localhost:2990/rest/api/2/",con.heal_uri("http://localhost:2990/login.jsp/rest/api/2")
    assert_equal "http://localhost:2990/jira/secure/Dashboard.jspa",con.heal_uri("http://localhost:2990/jira/secure/Dashboard.jspa") # If there is no Rest-Path at this point we have a problem
    assert_equal "http://localhost:2990/secure/Dashboard.jspa",con.heal_uri("http://localhost:2990/secure/Dashboard.jspa") # If there is no Rest-Path at this point we have a problem
  end

  def test_working_heal_uri!

    stub_request(:get, "http://test:1234@localhost:2990/jira//rest/api//2//dashboard").with(:headers => {'Accept'=>'*/*', 'Content-Type'=>'application/json;charset=UTF-8', 'User-Agent'=>'Ruby'}).to_return(:status => 404, :body => '<?xml version="1.0" encoding="UTF-8" standalone="yes"?><status><status-code>404</status-code><message>null for uri: http://localhost:2990/jira//rest/api//2//dashboard</message></status>', :headers => {"X-AUSERNAME" => "test" })

    ## First an URL we can fix
    cred = PasswordCredentials.new("http://localhost:2990/jira//rest/api//2//","test","1234")
    con = Connect.new(cred)
    assert_equal false,con.check_uri
    
    stub_request(:get, "http://test:1234@localhost:2990/jira/rest/api/2/dashboard").with(:headers => {'Accept'=>'*/*', 'Content-Type'=>'application/json;charset=UTF-8', 'User-Agent'=>'Ruby'}).to_return(:status => 200, :body => "", :headers => {})
    assert_equal "http://localhost:2990/jira/rest/api/2/", con.heal_uri!
    assert_equal true,con.check_uri
  end
  
  def test_notworking_heal_uri!
    stub_request(:get, "http://test:1234@localhost:2990/secure/Dashboard.jspadashboard").with(:headers => {'Accept'=>'*/*', 'Content-Type'=>'application/json;charset=UTF-8', 'User-Agent'=>'Ruby'}).to_return(:status => 400, :body => "", :headers => {})
    ## And now one we cant't fix
    cred = PasswordCredentials.new("http://localhost:2990/secure/Dashboard.jspa","test","1234")
    con = Connect.new(cred)
    assert_equal false,con.check_uri
    assert_raises(Jirarest2::CouldNotHealURIError){ con.heal_uri! }
    assert_equal false,con.check_uri
  end
  
end
