# -*- coding: utf-8 -*-
require "minitest/autorun"
require "jirarest2/credentials"
require "jirarest2/connect"
require "jirarest2/services/issuelinktype"
require "webmock/minitest"


class TestIssueLinkType < MiniTest::Unit::TestCase
  def setup
    cred = PasswordCredentials.new("http://localhost:2990/jira/rest/api/2/","test","1234")
    @con = Connect.new(cred)
    stub_request(:get, "http://test:1234@localhost:2990/jira/rest/auth/latest/session").with(:headers => {'Accept'=>'*/*', 'Content-Type'=>'application/json;charset=UTF-8', 'User-Agent'=>'Ruby'}).to_return(:status => 200, :body => "", :headers => {})
  end

  def test_single_name
    stub_request(:get, "http://test:1234@localhost:2990/jira/rest/api/2/issueLinkType/10000").with(:headers => {'Accept'=>'*/*', 'Content-Type'=>'application/json;charset=UTF-8', 'User-Agent'=>'Ruby'}).to_return(:status => 200, :body => '{"id":"10000","name":"Blocks","inward":"is blocked by","outward":"blocks","self":"http://localhost:2990/jira/rest/api/2/issueLinkType/10000"}', :headers => {})
    singlelinktype = IssueLinkType.new(@con,"10000")
    assert_equal "10000", singlelinktype.get["id"]
    assert_equal ["Blocks", "outward"], singlelinktype.name("blocks")
    assert_equal ["Blocks", "inward"], singlelinktype.name("is blocked by")
  end
  def test_multiple_name
    stub_request(:get, "http://test:1234@localhost:2990/jira/rest/api/2/issueLinkType").with(:headers => {'Accept'=>'*/*', 'Content-Type'=>'application/json;charset=UTF-8', 'User-Agent'=>'Ruby'}).to_return(:status => 200, :body => '{"issueLinkTypes":[{"id":"10000","name":"Blocks","inward":"is blocked by","outward":"blocks","self":"http://localhost:2990/jira/rest/api/2/issueLinkType/10000"},{"id":"10001","name":"Cloners","inward":"is cloned by","outward":"clones","self":"http://localhost:2990/jira/rest/api/2/issueLinkType/10001"},{"id":"10002","name":"Duplicate","inward":"is duplicated by","outward":"duplicates","self":"http://localhost:2990/jira/rest/api/2/issueLinkType/10002"},{"id":"10003","name":"Relates","inward":"relates to","outward":"relates to","self":"http://localhost:2990/jira/rest/api/2/issueLinkType/10003"}]}', :headers => {})
    linktype = IssueLinkType.new(@con)
    assert_equal ["Cloners", "outward"], linktype.name("clones")
    assert_equal ["Cloners", "inward"], linktype.name("is cloned by")
    assert_equal nil, linktype.name("unknown")
  end

  def test_internal_name?
    stub_request(:get, "http://test:1234@localhost:2990/jira/rest/api/2/issueLinkType/10000").with(:headers => {'Accept'=>'*/*', 'Content-Type'=>'application/json;charset=UTF-8', 'User-Agent'=>'Ruby'}).to_return(:status => 200, :body => '{"id":"10000","name":"Blocks","inward":"is blocked by","outward":"blocks","self":"http://localhost:2990/jira/rest/api/2/issueLinkType/10000"}', :headers => {})
    singlelinktype = IssueLinkType.new(@con,"10000")
    assert_equal false,singlelinktype.internal_name?("blocks")
    assert_equal true, singlelinktype.internal_name?("Blocks")
  end
  def test_multiple_internal_name
    stub_request(:get, "http://test:1234@localhost:2990/jira/rest/api/2/issueLinkType").with(:headers => {'Accept'=>'*/*', 'Content-Type'=>'application/json;charset=UTF-8', 'User-Agent'=>'Ruby'}).to_return(:status => 200, :body => '{"issueLinkTypes":[{"id":"10000","name":"Blocks","inward":"is blocked by","outward":"blocks","self":"http://localhost:2990/jira/rest/api/2/issueLinkType/10000"},{"id":"10001","name":"Cloners","inward":"is cloned by","outward":"clones","self":"http://localhost:2990/jira/rest/api/2/issueLinkType/10001"},{"id":"10002","name":"Duplicate","inward":"is duplicated by","outward":"duplicates","self":"http://localhost:2990/jira/rest/api/2/issueLinkType/10002"},{"id":"10003","name":"Relates","inward":"relates to","outward":"relates to","self":"http://localhost:2990/jira/rest/api/2/issueLinkType/10003"}]}', :headers => {})
    linktype = IssueLinkType.new(@con)
    assert_equal false,linktype.internal_name?("blocks")
    assert_equal true, linktype.internal_name?("Cloners")
  end
  
  def test_single_valid_names
    stub_request(:get, "http://test:1234@localhost:2990/jira/rest/api/2/issueLinkType/10000").with(:headers => {'Accept'=>'*/*', 'Content-Type'=>'application/json;charset=UTF-8', 'User-Agent'=>'Ruby'}).to_return(:status => 200, :body => '{"id":"10000","name":"Blocks","inward":"is blocked by","outward":"blocks","self":"http://localhost:2990/jira/rest/api/2/issueLinkType/10000"}', :headers => {})
    singlelinktype = IssueLinkType.new(@con,"10000")
    assert_equal "Blocks, is blocked by, blocks",singlelinktype.valid_names
  end
  def test_multiple_valid_names
    stub_request(:get, "http://test:1234@localhost:2990/jira/rest/api/2/issueLinkType").with(:headers => {'Accept'=>'*/*', 'Content-Type'=>'application/json;charset=UTF-8', 'User-Agent'=>'Ruby'}).to_return(:status => 200, :body => '{"issueLinkTypes":[{"id":"10000","name":"Blocks","inward":"is blocked by","outward":"blocks","self":"http://localhost:2990/jira/rest/api/2/issueLinkType/10000"},{"id":"10001","name":"Cloners","inward":"is cloned by","outward":"clones","self":"http://localhost:2990/jira/rest/api/2/issueLinkType/10001"},{"id":"10002","name":"Duplicate","inward":"is duplicated by","outward":"duplicates","self":"http://localhost:2990/jira/rest/api/2/issueLinkType/10002"},{"id":"10003","name":"Relates","inward":"relates to","outward":"relates to","self":"http://localhost:2990/jira/rest/api/2/issueLinkType/10003"}]}', :headers => {})

    linktype = IssueLinkType.new(@con)
    block = Regexp.new("blocks, Cloners, is cloned by,")
    assert_match block,  linktype.valid_names
    block = Regexp.new("blocks\nCloners\nis cloned by\n")
    assert_match block, linktype.valid_names("\n")
    
  end

  
end
