# -*- coding: utf-8 -*-
require "minitest/autorun"
require "credentials"
require "connect"
require "services/issuelink"

class TestIssueLink < MiniTest::Unit::TestCase
  def setup
    cred = Credentials.new("http://localhost:2990/jira/rest/api/2/","test","1234")
    @con = Connect.new(cred)
  end

  def test_link_issue
    link = IssueLink.new(@con)
    # check for right to link.
    assert_raises(Jirarest2::AuthentificationError) {
      link.link_issue("MFTP-6","SP-2","Blocks")
    }
    # check for bullshio issuelinktype
    assert_raises(Jirarest2::ValueNotAllowedException) {
      link.link_issue("SP-2","MFTP-6","Building")
    }
    # check for Basic link
    assert "201",link.link_issue("SP-2","MFTP-6","Blocks").code
    # Check for link type by name
    assert "201",link.link_issue("SP-2","MFTP-6","clones").code
    # Check for twisted "only onw way for links policy with jira", MFTP-6 to SP-3 would result in AuthError
    assert "201",link.link_issue("MFTP-6","SP-3","is cloned by")
  end
  
  def test_valid_issuelinktype
    link = IssueLink.new(@con)
    assert_match /blocks, Cloners, is cloned by,/,link.valid_issuelinktypes
  end
end
