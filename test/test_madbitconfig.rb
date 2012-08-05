require "minitest/autorun"
require "jirarest2/madbitconfig"
require "deb"

class TestConfig < MiniTest::Unit::TestCase

  def test_read_configfile
    testdir =  File.dirname(__FILE__)
    testfile = testdir + "/data/test.config.data"
    # Should work
    testdata = {"username"=>"UsErNaMe", "password"=>"pAsSw0rD;", "URL"=>"https://jira.localhost:2990/jira"}
    assert_equal testdata,MadbitConfig::read_configfile(testfile)
    # And fail
    assert_raises(IOError) { MadbitConfig::read_configfile(testfile+"blah") }
  end

  def test_write_configfile
    testdir =  File.dirname(__FILE__)
    testfile = testdir + "/data/test.config.tmp"
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

  def test_readjfile
    testdir = File.dirname(__FILE__)
    testfile =  testdir + "/data/test.json"
    assert_equal ["One", "Two", "Three", "Four"],MadbitConfig::read_configfile(testfile)["Many Values"]
    testfile =  testdir + "/data/test.nojson"
    assert_equal " \\This is a summary. We prefer to use it, as is\\", MadbitConfig::read_configfile(testfile, true)["\\Summary\\ "] # Not really what we want but didn't know how to fix now
    testfile =  testdir + "/data/test.nojson1"
    assert_equal " One, Two, Three, Four",MadbitConfig::read_configfile(testfile, true)["Many Values "]
    
    # I dont' know how to run this test in a automated setup. How do we feed one of the files above to STDIN so the testscript gets the data?
    # pp MadbitConfig::read_configfile("-") 
  end
  
end
