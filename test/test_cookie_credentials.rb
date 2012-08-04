require "minitest/autorun"
require "jirarest2/cookie_credentials"
require "net/http"
require "webmock/minitest"
require "pp"

class TestCookieCredentials < MiniTest::Unit::TestCase
  
  def setup
    @cred = CookieCredentials.new("http://localhost:2990/jira/rest/api/2/")
    @header = ["a.xsrf.token=BP8Q-WXN6-SKX3-NB5M|11ca22ad2bf3467bee711e5b912536d1fb046a4a|lout; Path=/myapp", "JSESSIONID=6C3AE9205FFC6E0DEC3353C2D10745D8; Path=/"]
  end


  def test_bake_cookies
    result = {"a.xsrf.token"=> "BP8Q-WXN6-SKX3-NB5M|11ca22ad2bf3467bee711e5b912536d1fb046a4a|lout", "JSESSIONID"=>"6C3AE9205FFC6E0DEC3353C2D10745D8"}
    assert_equal result, @cred.bake_cookies(@header)
  end

  def test_set_cookies
    test_bake_cookies
  end

  def test_get_cookies
    result = "a.xsrf.token=BP8Q-WXN6-SKX3-NB5M|11ca22ad2bf3467bee711e5b912536d1fb046a4a|lout; JSESSIONID=6C3AE9205FFC6E0DEC3353C2D10745D8"
    @cred.bake_cookies(@header) # If this fails please see if test_bake_cookies fails as well
    assert_equal result, @cred.get_cookies 
  end

  def test_get_auth_header
    result = "a.xsrf.token=BP8Q-WXN6-SKX3-NB5M|11ca22ad2bf3467bee711e5b912536d1fb046a4a|lout; JSESSIONID=6C3AE9205FFC6E0DEC3353C2D10745D8"
    uri = URI(@cred.connecturl)
    @cred.bake_cookies(@header) # If this fails please see if test_bake_cookies fails as well
    req = Net::HTTP::Get.new(uri.request_uri)
    @cred.get_auth_header(req)
    assert_instance_of Net::HTTP::Get, req # make sure we  still got the right requestor class
    assert_equal result,req["Cookie"]
  end
  
  def test_login_failed
    stub_request(:post, "http://test:12345@localhost:2990/jira/rest/auth/latest/session").with(:body => "{\"username\":\"test\",\"password\":\"12345\"}",:headers => {'Accept'=>'*/*', 'Content-Type'=>'application/json;charset=UTF-8', 'User-Agent'=>'Ruby'}).to_return(:status => 401, :body => "", :headers => {})    
    assert_raises(Jirarest2::AuthenticationError) {
      @cred.login("test","12345")
    }
  end

  def test_login_successful
    stub_request(:post, "http://test:1234@localhost:2990/jira/rest/auth/latest/session").with(:body => "{\"username\":\"test\",\"password\":\"1234\"}",:headers => {'Accept'=>'*/*', 'Content-Type'=>'application/json;charset=UTF-8'}).to_return(:status => 200, :body => '{"session":{"name":"JSESSIONID","value":"E8FE2A7CDB3306672665739A8E88D674"}}', :headers => {"Set-Cookie" => ["JSESSIONID=E8FE2A7CDB3306672665739A8E88D674; Path=/","a.xsrf.token=BP8Q-WXN6-SKX3-NB5M|39554775813b531f7dcba4aa28bb13b20e602eb9|lin; Path=/jira"]})
    assert_equal "E8FE2A7CDB3306672665739A8E88D674", @cred.login("test","1234")
  end
  
  def test_logout # requires test_login_successful to succeed, so not really good :(   )
    stub_request(:post, "http://test:1234@localhost:2990/jira/rest/auth/latest/session").with(:body => "{\"username\":\"test\",\"password\":\"1234\"}",:headers => {'Accept'=>'*/*', 'Content-Type'=>'application/json;charset=UTF-8'}).to_return(:status => 200, :body => '{"session":{"name":"JSESSIONID","value":"E8FE2A7CDB3306672665739A8E88D674"}}', :headers => {"Set-Cookie" => ["JSESSIONID=E8FE2A7CDB3306672665739A8E88D674; Path=/","a.xsrf.token=BP8Q-WXN6-SKX3-NB5M|39554775813b531f7dcba4aa28bb13b20e602eb9|lin; Path=/jira"]})
    stub_request(:delete, "http://localhost:2990/jira/rest/auth/latest/session").with(:headers => {'Accept'=>'*/*', 'Content-Type'=>'application/json;charset=UTF-8', 'Cookie'=>'JSESSIONID=E8FE2A7CDB3306672665739A8E88D674; a.xsrf.token=BP8Q-WXN6-SKX3-NB5M|39554775813b531f7dcba4aa28bb13b20e602eb9|lin', 'User-Agent'=>'Ruby'}).to_return(:status => 204, :body => "", :headers => {})
    @cred.login("test","1234")
    assert_equal true,@cred.logout
  end

  def test_store_cookiejar
    @cred.cookiestore = File.dirname(__FILE__) + "/data/cookiejar"
    @cred.bake_cookies(@header)
    expect = {"a.xsrf.token"=>"BP8Q-WXN6-SKX3-NB5M|11ca22ad2bf3467bee711e5b912536d1fb046a4a|lout", "JSESSIONID"=>"6C3AE9205FFC6E0DEC3353C2D10745D8"}
    assert_equal expect, @cred.store_cookiejar
  end

  def test_load_cookiejar
    @cred.cookiestore = File.dirname(__FILE__) + "/data/cookiejar"
    @cred.load_cookiejar
    assert_equal "a.xsrf.token=BP8Q-WXN6-SKX3-NB5M|11ca22ad2bf3467bee711e5b912536d1fb046a4a|lout; JSESSIONID=6C3AE9205FFC6E0DEC3353C2D10745D8", @cred.get_cookies
  end

end
