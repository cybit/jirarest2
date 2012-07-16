require "minitest/autorun"
require "connect"
require "credentials"

class TestConnect < MiniTest::Unit::TestCase
  def setup
    cred = Credentials.new("http://localhost:2990/jira/rest/api/2/","test","1234")
    @con = Connect.new(cred)
  end
  

  def test_executeGET
    assert "projects", @con.execute("Get","issue/createmeta/","").result["expand"]
  end
  
  def test_executePOST
    query={"jql"=>"project = MFTP", "startAt"=>0, "maxResults"=>4 }
    assert 4, @con.execute("Post","search/",query).result["maxResults"]
  end

  def test_check_uri
    assert_equal true,@con.check_uri
    cred = Credentials.new("http://localhost:2990/rest/api/2/","test","1234")
    con1 = Connect.new(cred)
    assert_equal false,con1.check_uri
  end
  
  def test_heal_uri
    cred = Credentials.new("http://localhost:2990/jira//rest/api//2//","test","1234")
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

  def test_heal_uri!
    ## First an URL we can fix
    cred = Credentials.new("http://localhost:2990/jira//rest/api//2//","test","1234")
    con = Connect.new(cred)
    assert_equal false,con.check_uri
    assert_equal "http://localhost:2990/jira/rest/api/2/", con.heal_uri!
    assert_equal true,con.check_uri
    ## And now one we cant't fix
    cred = Credentials.new("http://localhost:2990/secure/Dashboard.jspa","test","1234")
    con = Connect.new(cred)
    assert_equal false,con.check_uri
    assert_raises(Jirarest2::CouldNotHealURIError){ con.heal_uri! }
    assert_equal false,con.check_uri
  end
  
end
