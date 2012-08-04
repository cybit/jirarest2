require "minitest/autorun"
require "jirarest2/password_credentials"

class TestPasswordCredentials < MiniTest::Unit::TestCase
  def setup
    @cred = PasswordCredentials.new("https://localhost:2990","username","password")
  end
  
  def testInitialize
    assert_instance_of(PasswordCredentials, @cred)
    assert_equal "https://localhost:2990", @cred.connecturl
    assert_equal "username", @cred.username
    assert_equal "password", @cred.password
  end

  def testSetPassword
    @cred.password = "1234"
    assert_equal "1234", @cred.password
  end

  def testSetUsername
    @cred.username = "test"
    assert_equal "test", @cred.username
  end

end
