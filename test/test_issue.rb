# -*- coding: utf-8 -*-
require "minitest/autorun"
require "jirarest2"

class TestIssue < MiniTest::Unit::TestCase
  def setup
    @credentials = Credentials.new("http://localhost:2990/jira/rest/api/2/","test","1234")
    @connect = Connect.new(@credentials)
    @existentIssue = Issue.new("MFTP","My issue type",@connect)
  end

  def testNonExistentProject
    assert_raises(Jirarest2::WrongProjectException) {
      nonexistentProject = Issue.new("blubber","fasel",@connect)
    }
  end
  
  def testNonExistentIssuetype
    assert_raises(Jirarest2::WrongIssuetypeException) {
      nonexistentIssue = Issue.new("MFTP","fasel",@connect)
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
    assert blankissue
    assert_equal "MFTP", blankissue["fields"]["project"]["key"]
    assert_equal "Summary Text", issue.get_field("Summary")
  end
  
end
