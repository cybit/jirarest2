require "minitest/autorun"
require "jirarest2/connect"
require "jirarest2/credentials"
require "jirarest2/result"

class TestResult < MiniTest::Unit::TestCase
  def setup
    cred = Credentials.new("http://localhost:2990/jira/rest/api/2/","test","1234")
    @con = Connect.new(cred)
  end

  def test_code
    assert "200", @con.execute("Get","issue/createmeta/","").code
  end

  def test_header
    assert "test", @con.execute("Get","issue/createmeta/","").header["x-ausername"]
  end
  
  def test_result
    assert "projects", @con.execute("Get","issue/createmeta/","").result["expand"]
  end
  
  
  def test_body
    assert_match "http://localhost:2990/jira/rest/api/2/project", @con.execute("Get","issue/createmeta/","").body
  end
  
end
