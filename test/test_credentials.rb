require "minitest/autorun"
require "jirarest2/credentials"
require "jirarest2/exceptions"

class TestCredentials < MiniTest::Unit::TestCase
  def setup
    @cred = Credentials.new("https://localhost:2990","test")
  end
  
  def testInitialize
    assert_instance_of(Credentials, Credentials.new("https://localhost:2990","test"))
    assert_raises(Jirarest2::NotAnURLError)  {
      Credentials.new("localhost:2990","Minime")
    }
    assert_equal "https://localhost:2990", @cred.connecturl
  end

  def testSetURL
    @cred.connecturl = "http://localhost:80"
    assert_equal "http://localhost:80", @cred.connecturl 
    assert_raises(Jirarest2::NotAnURLError) {
      @cred.connecturl = "localhost:80" 
    }
  end
  
  def test_baseurl
    cre = Credentials.new("https://localhost:2990/blah/blubb/rest/api/latest","test")
    assert_equal "https://localhost:2990/blah/blubb/rest/",cre.baseurl
  end
  
end
