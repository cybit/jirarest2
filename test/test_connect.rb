require "minitest/autorun"
require "connect"
require "credentials"

class TestConnect < MiniTest::Unit::TestCase
  def setup
    cred = Credentials.new("http://localhost:2990/jira/rest/api/2/","test","1234")
    @con = Connect.new(cred)
  end
  

  def test_get_get_reponse
    assert "projects", @con.get_response("createmeta","")["expand"]
  end
  
  def test_post_connection
    query={"jql"=>"project = MFTP", "startAt"=>0, "maxResults"=>4 }
    assert 4, @con.get_response("search",query)["maxResults"]
  end
  
end
