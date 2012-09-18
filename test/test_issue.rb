# -*- coding: utf-8 -*-
require "minitest/autorun"
require "jirarest2/connect"
require "jirarest2/credentials"
require "jirarest2/password_credentials"
require "jirarest2/cookie_credentials"
require "jirarest2/issue"
require "pp"
require "webmock/minitest"

class TestIssue < MiniTest::Unit::TestCase

  def setup 
    cred = PasswordCredentials.new("http://localhost:2990/jira/rest/api/2/","test","1234")
    @con = Connect.new(cred)
    stub_request(:get, "http://test:1234@localhost:2990/jira/rest/auth/latest/session").with(:headers => {'Accept'=>'*/*', 'Content-Type'=>'application/json;charset=UTF-8', 'User-Agent'=>'Ruby'}).to_return(:status => 200, :body => "", :headers => {})

  end
  
  def test_receive
    issue = Issue.new("SP-2")
# @todo write tests
#    WebMock.disable!
#    ppp issue.receive(@con)
#    WebMock.enable!
  end

  def test_set_assignee_no_rights
    stub_request(:put, "http://test:1234@localhost:2990/jira/rest/api/2/issue/SP-2/assignee").with(:body => "{\"name\":\"cebit\"}",:headers => {'Accept'=>'*/*', 'Content-Type'=>'application/json;charset=UTF-8', 'User-Agent'=>'Ruby'}).to_return(:status => 403, :body => "", :headers => {})
    issue = Issue.new("SP-2")
    assert_raises(Jirarest2::ForbiddenError) {
      issue.set_assignee(@con,"cebit")
    }
  end

  def test_set_assignee_with_rights
    stub_request(:put, "http://test:1234@localhost:2990/jira/rest/api/2/issue/SP-2/assignee").with(:body => "{\"name\":\"cebit\"}",:headers => {'Accept'=>'*/*', 'Content-Type'=>'application/json;charset=UTF-8', 'User-Agent'=>'Ruby'}).to_return(:status => 204, :body => "", :headers => {})
    issue = Issue.new("SP-2")
    assert_equal true,issue.set_assignee(@con,"cebit")
  end

  def test_remove_assignee
    stub_request(:get, "http://admin:admin@localhost:2990/jira/rest/auth/latest/session").with(:headers => {'Accept'=>'*/*', 'Content-Type'=>'application/json;charset=UTF-8', 'User-Agent'=>'Ruby'}).to_return(:status => 200, :body => "", :headers => {})
    stub_request(:put, "http://admin:admin@localhost:2990/jira/rest/api/2/issue/SP-2/assignee").with(:body => "null",:headers => {'Accept'=>'*/*', 'Content-Type'=>'application/json;charset=UTF-8', 'User-Agent'=>'Ruby'}).to_return(:status => 204, :body => "", :headers => {})
    cred = PasswordCredentials.new("http://localhost:2990/jira/rest/api/2/","admin","admin")
    con = Connect.new(cred)
    issue = Issue.new("SP-2")
    assert_equal true,issue.remove_assignee(con)
  end
end

