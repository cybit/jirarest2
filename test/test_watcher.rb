# -*- coding: utf-8 -*-
require "minitest/autorun"
require "credentials"
require "connect"
require "services/watcher"

class TestWatcher < MiniTest::Unit::TestCase
  def setup
    cred = Credentials.new("http://localhost:2990/jira/rest/api/2/","test","1234")
    @con = Connect.new(cred)
  end
  
  def test_get_watchers
    watchers = Watcher.new(@con,"MFTP-7")
    assert ["admin","cebit","test"], watchers.get_watchers
    assert [], Watcher.new(@con,"MFTP-3")
  end
  
  def test_delete_watcher
    watchers = Watcher.new(@con,"MFTP-7")
    assert_raises(Jirarest2::AuthentificationError) { 
      watchers.remove_watcher("cebit")
    }
  end

  def test_add_watcher
    watcherna = Watcher.new(@con, "MFTP-2")
    assert_raises(Jirarest2::AuthentificationError) {
      watcherna.add_watcher("cebit")
    }
    watchers = Watcher.new(@con, "SP-1")
    assert true, watchers.add_watcher("cebit")
  end

end
