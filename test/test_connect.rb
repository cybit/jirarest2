require "minitest/autorun"
require "connect"
require "credentials"

class TestConnect < MiniTest::Unit::TestCase
  def setup
    cred = Credentials.new("http://localhost:2990/jira/rest/api/2/","test","1234")
    @con = Connect.new(cred)
  end
  

  def test_executeGET
    assert "projects", @con.execute("Get","issue/createmeta/","")["expand"]
  end
  
  def test_executePOST
    query={"jql"=>"project = MFTP", "startAt"=>0, "maxResults"=>4 }
    assert 4, @con.execute("Post","search/",query)["maxResults"]
  end
  
end
