# -*- coding: utf-8 -*-
require "minitest/autorun"
require "jirarest2"
require "webmock/minitest"

class TestNewIssue < MiniTest::Unit::TestCase
  def setup
    @credentials = PasswordCredentials.new("http://localhost:2990/jira/rest/api/2/","test","1234")
    @connect = Connect.new(@credentials)
    raw_response_file = File.new(File.dirname(__FILE__)+"/data/issuespec.txt")
    stub_request(:get, "http://test:1234@localhost:2990/jira/rest/api/2/issue/createmeta/?expand=projects.issuetypes.fields&issuetypeNames=My%20issue%20type&projectKeys=MFTP").with(:headers => {'Accept'=>'*/*', 'Content-Type'=>'application/json;charset=UTF-8', 'User-Agent'=>'Ruby'}).to_return(raw_response_file)
    stub_request(:get, "http://test:1234@localhost:2990/jira/rest/auth/latest/session").with(:headers => {'Accept'=>'*/*', 'Content-Type'=>'application/json;charset=UTF-8', 'User-Agent'=>'Ruby'}).to_return(:status => 200, :body => "", :headers => {})
    @existentIssue = NewIssue.new("MFTP","My issue type",@connect)
  end

  def testNonExistentProject
    stub_request(:get, "http://test:1234@localhost:2990/jira/rest/api/2/issue/createmeta/?expand=projects.issuetypes.fields&issuetypeNames=fasel&projectKeys=blubber").with(:headers => {'Accept'=>'*/*', 'Content-Type'=>'application/json;charset=UTF-8', 'User-Agent'=>'Ruby'}).to_return(:status => 200, :body => '{"expand":"projects","projects":[]}', :headers => {})
    assert_raises(Jirarest2::WrongProjectException) {
      NewIssue.new("blubber","fasel",@connect)
    }
  end

  def testNonExistentIssuetype
    stub_request(:get, "http://test:1234@localhost:2990/jira/rest/api/2/issue/createmeta/?expand=projects.issuetypes.fields&issuetypeNames=fasel&projectKeys=MFTP").with(:headers => {'Accept'=>'*/*', 'Content-Type'=>'application/json;charset=UTF-8', 'User-Agent'=>'Ruby'}).to_return(:status => 200, :body => '{"expand":"projects","projects":[{"expand":"issuetypes","self":"http://localhost:2990/jira/rest/api/2/project/MFTP","id":"10000","key":"MFTP","name":"My first Test Project","avatarUrls":{"16x16":"http://localhost:2990/jira/secure/projectavatar?size=small&pid=10000&avatarId=10011","48x48":"http://localhost:2990/jira/secure/projectavatar?pid=10000&avatarId=10011"},"issuetypes":[]}]}', :headers => {})
    assert_raises(Jirarest2::WrongIssuetypeException) {
      NewIssue.new("MFTP","fasel",@connect)
    }
  end
  
  def testExistent
    assert_equal "My issue type", @existentIssue.issuetype
  end
  
  def test_get_requireds
    req = @existentIssue.get_requireds
    assert_equal true, req.include?("Summary")
  end

  def test_get_fieldnames
    req = @existentIssue.get_fieldnames
    assert_equal true, req.include?("Priority")
  end

  def test_jirahash
    issue =  @existentIssue
    issue.set_field("Summary","Summary Text")
    issue.set_field("Großes Text","My own text as well")
    issue.set_field("Description","And a little bit for \n the big \n text field")
    issue.set_field("Priority","Trivial")
    issue.set_field("List select","Räuber")
    issue.set_field("Multi Select",["Glocke","Kabale und Liebe"])
    blankissue = issue.jirahash
    assert_equal "MFTP", blankissue["fields"]["project"]["key"]
    assert_equal "Summary Text", issue.get_field("Summary")
  end


  def test_persist
    issue = @existentIssue
    issue.set_field("Summary","Summary Text")
    issue.set_field("Priority","Trivial")
    stub_request(:post, "http://test:1234@localhost:2990/jira/rest/api/2/issue/").with(:body => "{\"fields\":{\"summary\":\"Summary Text\",\"issuetype\":{\"name\":\"My issue type\"},\"project\":{\"key\":\"MFTP\"},\"priority\":{\"name\":\"Trivial\"}}}",:headers => {'Accept'=>'*/*', 'Content-Type'=>'application/json;charset=UTF-8', 'User-Agent'=>'Ruby'}).to_return(:status => 201, :body => '{"id":"10608","key":"MFTP-11","self":"http://localhost:2990/jira/rest/api/2/issue/10608"}', :headers => {})

    issue.persist(@connect)
  end

  
end
