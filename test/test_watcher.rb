# -*- coding: utf-8 -*-
require "minitest/autorun"
require "jirarest2/credentials"
require "jirarest2/connect"
require "jirarest2/services/watcher"
require "webmock/minitest"

class TestWatcher < MiniTest::Unit::TestCase
  def setup
    cred = Credentials.new("http://localhost:2990/jira/rest/api/2/","test","1234")
    @con = Connect.new(cred)
  end
  
  def test_get_watchers_filled
    stub_request(:get, "http://test:1234@localhost:2990/jira/rest/api/2/issue/MFTP-7/watchers").with(:headers => {'Accept'=>'*/*', 'Content-Type'=>'application/json;charset=UTF-8', 'User-Agent'=>'Ruby'}).to_return(:status => 200, :body => '{"self":"http://localhost:2990/jira/rest/api/2/issue/MFTP-7/watchers","isWatching":true,"watchCount":3,"watchers":[{"self":"http://localhost:2990/jira/rest/api/2/user?username=admin","name":"admin","avatarUrls":{"16x16":"http://localhost:2990/jira/secure/useravatar?size=small&avatarId=10122","48x48":"http://localhost:2990/jira/secure/useravatar?avatarId=10122"},"displayName":"admin","active":true},{"self":"http://localhost:2990/jira/rest/api/2/user?username=cebit","name":"cebit","avatarUrls":{"16x16":"http://localhost:2990/jira/secure/useravatar?size=small&avatarId=10122","48x48":"http://localhost:2990/jira/secure/useravatar?avatarId=10122"},"displayName":"Cyril Bitterich","active":true},{"self":"http://localhost:2990/jira/rest/api/2/user?username=test","name":"test","avatarUrls":{"16x16":"http://localhost:2990/jira/secure/useravatar?size=small&avatarId=10122","48x48":"http://localhost:2990/jira/secure/useravatar?avatarId=10122"},"displayName":"Test User","active":true}]}', :headers => {})
    watchers = Watcher.new(@con,"MFTP-7")
    assert_equal ["admin","cebit","test"], watchers.get_watchers
  end
  
  def test_get_watchers_empty
    stub_request(:get, "http://test:1234@localhost:2990/jira/rest/api/2/issue/MFTP-3/watchers").with(:headers => {'Accept'=>'*/*', 'Content-Type'=>'application/json;charset=UTF-8', 'User-Agent'=>'Ruby'}).to_return(:status => 200, :body => '{"self":"http://localhost:2990/jira/rest/api/2/issue/MFTP-3/watchers","isWatching":false,"watchCount":0,"watchers":[]}', :headers => {})
    watchers = Watcher.new(@con,"MFTP-3")
    assert_equal [], watchers.get_watchers
  end
  
  def test_delete_watcher
    stub_request(:delete, "http://test:1234@localhost:2990/jira/rest/api/2/issue/MFTP-7/watchers?username=cebit").with(:headers => {'Accept'=>'*/*', 'Content-Type'=>'application/json;charset=UTF-8', 'User-Agent'=>'Ruby'}).to_return(:status => 401, :body => '{"errorMessages":["User \'test\' is not allowed to remove watchers from issue \'MFTP-7\'"],"errors":{}}', :headers => {})

    watchers = Watcher.new(@con,"MFTP-7")
    assert_raises(Jirarest2::AuthentificationError) { 
      watchers.remove_watcher("cebit")
    }
  end

  def test_add_watcher_fail
    stub_request(:post, "http://test:1234@localhost:2990/jira/rest/api/2/issue/MFTP-2/watchers").with(:body => "\"cebit\"", :headers => {'Accept'=>'*/*', 'Content-Type'=>'application/json;charset=UTF-8', 'User-Agent'=>'Ruby'}).to_return(:status => 401, :body => '{"errorMessages":["User \'test\' is not allowed to add watchers to issue \'MFTP-2\'"],"errors":{}}', :headers => {})

    watcherna = Watcher.new(@con, "MFTP-2")
    assert_raises(Jirarest2::AuthentificationError) {
      watcherna.add_watcher("cebit")
    }
  end
  def test_add_watcher_success
    stub_request(:post, "http://test:1234@localhost:2990/jira/rest/api/2/issue/SP-1/watchers").with(:body => "\"cebit\"",:headers => {'Accept'=>'*/*', 'Content-Type'=>'application/json;charset=UTF-8', 'User-Agent'=>'Ruby'}).to_return(:status => 204, :headers => {})
    watchers = Watcher.new(@con, "SP-1")
    assert true, watchers.add_watcher("cebit")
  end

end
