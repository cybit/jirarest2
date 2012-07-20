# -*- coding: utf-8 -*-
require "minitest/autorun"
require "jirarest2/credentials"
require "jirarest2/connect"
require "jirarest2/services/issuelinktype"


class TestIssueLinkType < MiniTest::Unit::TestCase
  def setup
    cred = Credentials.new("http://localhost:2990/jira/rest/api/2/","test","1234")
    @con = Connect.new(cred)
  end

  def test_name
    singlelinktype = IssueLinkType.new(@con,"10000")
    linktype = IssueLinkType.new(@con)
    assert_equal "10000", singlelinktype.get["id"]
    assert_equal ["Blocks", "outward"], singlelinktype.name("blocks")
    assert_equal ["Blocks", "inward"], singlelinktype.name("is blocked by")
    assert_equal ["Cloners", "outward"], linktype.name("clones")
    assert_equal ["Cloners", "inward"], linktype.name("is cloned by")
    assert_equal nil, linktype.name("unknown")
  end

  def test_internal_name?
    singlelinktype = IssueLinkType.new(@con,"10000")
    assert_equal false,singlelinktype.internal_name?("blocks")
    assert_equal true, singlelinktype.internal_name?("Blocks")
    linktype = IssueLinkType.new(@con)
    assert_equal false,linktype.internal_name?("blocks")
    assert_equal true, linktype.internal_name?("Cloners")
  end
  
  def test_valid_names
    singlelinktype = IssueLinkType.new(@con,"10000")
    assert_equal "Blocks, is blocked by, blocks",singlelinktype.valid_names
    linktype = IssueLinkType.new(@con)
    assert_match /blocks, Cloners, is cloned by,/,linktype.valid_names
    assert_match /blocks\nCloners\nis cloned by\n/,linktype.valid_names("\n")
    
  end

  
end
