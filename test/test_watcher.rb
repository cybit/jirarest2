require "minitest/autorun"
require "credentials"
require "connect"
require "watcher"

class TestWatcher < MiniTest::Unit::TestCase
  def setup
    cred = Credentials.new("http://localhost:2990/jira/rest/api/2/","test","1234")
    @con = Connect.new(cred)
  end
  
  def test_get_watchers
    watchers = Watcher.new(@con,"MFTP-7")
    pp watchers.get_watchers
  end
  
  def test_delete_watcher
    watchers = Watcher.new(@con,"MFTP-7")
    assert_raises(Jirarest2::AuthentificationError) { 
      pp watchers.remove_watcher("cebit")
    }
  end

end
