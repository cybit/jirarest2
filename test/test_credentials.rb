require "minitest/autorun"
require "jirarest2"

class TestCredentials < MiniTest::Unit::TestCase
  def setup
    @cred = Credentials.new("https://localhost:2990","username","password")
    @credc =  Credentials.new("https://localhost:2990","username","password")
  end
  
  def testInitialize
    assert_instance_of(Credentials, Credentials.new("https://localhost:2990","username","password") )
    assert_raises(Jirarest2::NotAnURLError)  {
      Credentials.new("localhost:2990","username","password")
    }
    assert_equal "https://localhost:2990", @cred.connecturl
    assert_equal "username", @cred.username
    assert_equal "password", @cred.password
  end

  def testSetURL
    @credc.connecturl = "http://localhost:80"
    assert_equal "http://localhost:80", @credc.connecturl 
    assert_raises(Jirarest2::NotAnURLError) {
      @credc.connecturl = "localhost:80" 
    }
  end
  
  def testSetPassword
    @credc.password = "1234"
    assert_equal "1234", @credc.password
  end

  def testSetUsername
    @credc.username = "test"
    assert_equal "test", @credc.username
  end

end
