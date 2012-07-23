# -*- coding: utf-8 -*-
require "minitest/autorun"
require "jirarest2/credentials"
require "jirarest2/connect"
require "jirarest2/services/issuelink"
require "webmock/minitest"


class TestIssueLink < MiniTest::Unit::TestCase
  def setup
    cred = Credentials.new("http://localhost:2990/jira/rest/api/2/","test","1234")
    @con = Connect.new(cred)
    stub_request(:get, "http://test:1234@localhost:2990/jira/rest/api/2/issueLinkType").with(:headers => {'Accept'=>'*/*', 'Content-Type'=>'application/json;charset=UTF-8', 'User-Agent'=>'Ruby'}).to_return(:status => 200, :body => '{"issueLinkTypes":[{"id":"10000","name":"Blocks","inward":"is blocked by","outward":"blocks","self":"http://localhost:2990/jira/rest/api/2/issueLinkType/10000"},{"id":"10001","name":"Cloners","inward":"is cloned by","outward":"clones","self":"http://localhost:2990/jira/rest/api/2/issueLinkType/10001"},{"id":"10002","name":"Duplicate","inward":"is duplicated by","outward":"duplicates","self":"http://localhost:2990/jira/rest/api/2/issueLinkType/10002"},{"id":"10003","name":"Relates","inward":"relates to","outward":"relates to","self":"http://localhost:2990/jira/rest/api/2/issueLinkType/10003"}]}', :headers => {})
    @link = IssueLink.new(@con)
  end


  def test_link_issue_access
    # check for right to link.
    stub_request(:post, "http://test:1234@localhost:2990/jira/rest/api/2/issueLink").with(:body => "{\"type\":{\"name\":\"Blocks\"},\"inwardIssue\":{\"key\":\"MFTP-6\"},\"outwardIssue\":{\"key\":\"SP-2\"}}",:headers => {'Accept'=>'*/*', 'Content-Type'=>'application/json;charset=UTF-8', 'User-Agent'=>'Ruby'}).to_return(:status => 401, :body => '{"errorMessages":["No Link Issue Permission for issue \'MFTP-6\'"],"errors":{}}', :headers => {})
    assert_raises(Jirarest2::AuthentificationError) {
      @link.link_issue("MFTP-6","SP-2","Blocks")
    }
  end

  def test_link_issue_badlinktype
    # check for bullshio issuelinktype
    assert_raises(Jirarest2::ValueNotAllowedException) {
        @link.link_issue("SP-2","MFTP-6","Building")
    }
  end

  def test_link_issue_byname
    # check for Basic link
    stub_request(:post, "http://test:1234@localhost:2990/jira/rest/api/2/issueLink").with(:body => "{\"type\":{\"name\":\"Blocks\"},\"inwardIssue\":{\"key\":\"SP-2\"},\"outwardIssue\":{\"key\":\"MFTP-6\"}}",:headers => {'Accept'=>'*/*', 'Content-Type'=>'application/json;charset=UTF-8', 'User-Agent'=>'Ruby'}).to_return(:status => 201, :body => "", :headers => {})
    assert_equal "201",@link.link_issue("SP-2","MFTP-6","Blocks").code
  end

  def test_link_issue_byuiname
    # Check for link type by name
    stub_request(:post, "http://test:1234@localhost:2990/jira/rest/api/2/issueLink").with(:body => "{\"type\":{\"name\":\"Cloners\"},\"inwardIssue\":{\"key\":\"SP-2\"},\"outwardIssue\":{\"key\":\"MFTP-6\"}}",:headers => {'Accept'=>'*/*', 'Content-Type'=>'application/json;charset=UTF-8', 'User-Agent'=>'Ruby'}).to_return(:status => 201, :body => "", :headers => {})
    assert_equal "201",@link.link_issue("SP-2","MFTP-6","clones").code
  end

  def test_link_issue_changearound
    # Check for twisted "only onw way for links policy with jira", MFTP-6 to SP-3 would result in AuthError
    stub_request(:post, "http://test:1234@localhost:2990/jira/rest/api/2/issueLink").with(:body => "{\"type\":{\"name\":\"Cloners\"},\"inwardIssue\":{\"key\":\"SP-3\"},\"outwardIssue\":{\"key\":\"MFTP-6\"}}", :headers => {'Accept'=>'*/*', 'Content-Type'=>'application/json;charset=UTF-8', 'User-Agent'=>'Ruby'}).to_return(:status => 201, :body => "", :headers => {})
    assert_equal "201",@link.link_issue("MFTP-6","SP-3","is cloned by").code
  end

  def test_valid_issuelinktype
     block = Regexp.new("blocks, Cloners, is cloned by,")
     assert_match block, @link.valid_issuelinktypes
  end

end
