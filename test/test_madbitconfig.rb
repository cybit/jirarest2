require "minitest/autorun"
require "madbitconfig"
require "pp"

class TestConfig < MiniTest::Unit::TestCase

  def test_read_configfile
    testdir =  File.dirname($0)
    testfile = testdir + "/test/data/test.config.data"
    # Should work
    testdata = {"username"=>"UsErNaMe", "password"=>"pAsSw0rD;", "URL"=>"https://jira.localhost:2990/jira"}
    assert_equal testdata,MadbitConfig::read_configfile(testfile)
    # And fail
    assert_raises(IOError) { MadbitConfig::read_configfile(testfile+"blah") }
  end

  def test_write_configfile
    testdir =  File.dirname($0)
    testfile = testdir + "/test/data/test.config.tmp"
    #make sure
    File.delete(testfile) if File.exists?(testfile) 
    #test
    confighash = {"Param1" => "Value1", "Parameter 2" => "Value 2", "password" => " pAsSw0rD;21"}
    assert_equal confighash,MadbitConfig::write_configfile(testfile,confighash)
    assert_raises(MadbitConfig::FileExistsException) { MadbitConfig::write_configfile(testfile,confighash) }
    assert_equal confighash,MadbitConfig::write_configfile(testfile,confighash,:force)
    # cleanup
    File.delete(testfile) if File.exists?(testfile)
    
  end

  
end
