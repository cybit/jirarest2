require "minitest/autorun"
require "webmock/minitest"
require "jirarest2/connect"
require "jirarest2/credentials"
require "jirarest2/services/comment"

class TestComment < MiniTest::Unit::TestCase
  def setup
    cred = PasswordCredentials.new("http://localhost:2990/jira/rest/api/2/","test","1234")
    @con = Connect.new(cred)
    stub_request(:get, "http://test:1234@localhost:2990/jira/rest/auth/latest/session").with(:headers => {'Accept'=>'*/*', 'Content-Type'=>'application/json;charset=UTF-8', 'User-Agent'=>'Ruby'}).to_return(:status => 200, :body => "", :headers => {})

  end

  def test_get_comment_filled
    comment = Comment.new(@con,"SP-15")
    raw_response_file = File.new(File.dirname(__FILE__)+"/data/get-comments.txt")
    stub_request(:get, "http://test:1234@localhost:2990/jira/rest/api/2/issue/SP-15/comment").with(:headers => {'Accept'=>'*/*', 'Content-Type'=>'application/json;charset=UTF-8', 'User-Agent'=>'Ruby'}).to_return(raw_response_file)
    result =  comment.get
    assert_equal 4,result.size
    assert_equal "2nd comment", result[1].text
    assert_equal true, Time.parse("2012-07-29 18:44:03 +0200").ctime == result[3].mdate.ctime
  end

  def test_get_comment_empty
    comment = Comment.new(@con,"SP-14")
    stub_request(:get, "http://test:1234@localhost:2990/jira/rest/api/2/issue/SP-14/comment").with(:headers => {'Accept'=>'*/*', 'Content-Type'=>'application/json;charset=UTF-8', 'User-Agent'=>'Ruby'}).to_return(:status => 200, :body => '{"startAt":0,"maxResults":0,"total":0,"comments":[]}', :headers => {})
    assert_equal nil, comment.get
  end

  def test_add_comment_fail
    stub_request(:post, "http://test:1234@localhost:2990/jira/rest/api/2/issue/SP-3/comment").with(:body => "{\"body\":\"\"}", :headers => {'Accept'=>'*/*', 'Content-Type'=>'application/json;charset=UTF-8', 'User-Agent'=>'Ruby'}).to_return(:status => 400, :body => '{"errorMessages":[],"errors":{"comment":"Comment body can not be empty!"}}', :headers => {})
    comment = Comment.new(@con,"SP-3")
    assert_raises(Jirarest2::BadRequestError) {
      comment.add("")
    }
    stub_request(:post, "http://test:1234@localhost:2990/jira/rest/api/2/issue/SPP-3/comment").with(:headers => {'Accept'=>'*/*', 'Content-Type'=>'application/json;charset=UTF-8', 'User-Agent'=>'Ruby'}).to_return(:status => 404, :body => '{"errorMessages":["Issue Does Not Exist"],"errors":{}}', :headers => {})
    comment = Comment.new(@con,"SPP-3")
    assert_raises(Jirarest2::NotFoundError) {
      comment.add("Text")
    }
  end

  def test_add_comment_success
    stub_request(:post, "http://test:1234@localhost:2990/jira/rest/api/2/issue/SP-3/comment").with(:body => "{\"body\":\"Text for the long run\"}",:headers => {'Accept'=>'*/*', 'Content-Type'=>'application/json;charset=UTF-8', 'User-Agent'=>'Ruby'}).to_return(:status => 201, :body => '{"self":"http://localhost:2990/jira/rest/api/2/issue/10104/comment/10110","id":"10110","author":{"self":"http://localhost:2990/jira/rest/api/2/user?username=test","name":"test","emailAddress":"jira-test@localhost","avatarUrls":{"16x16":"http://localhost:2990/jira/secure/useravatar?size=small&avatarId=10122","48x48":"http://localhost:2990/jira/secure/useravatar?avatarId=10122"},"displayName":"Test User","active":true},"body":"Text for the long run","updateAuthor":{"self":"http://localhost:2990/jira/rest/api/2/user?username=test","name":"test","emailAddress":"jira-test@localhost","avatarUrls":{"16x16":"http://localhost:2990/jira/secure/useravatar?size=small&avatarId=10122","48x48":"http://localhost:2990/jira/secure/useravatar?avatarId=10122"},"displayName":"Test User","active":true},"created":"2012-07-27T20:36:07.832+0200","updated":"2012-07-27T20:36:07.832+0200"}', :headers => {})

    comment = Comment.new(@con,"SP-3")
    match = Regexp.new(',"body":"Text for the long run","updateAuthor"')
    assert_match match, comment.add("Text for the long run").body
    assert_instance_of Jirarest2::Result, comment.add("Text for the long run")
  end

  def test_get_special_comment_fail
    comment = Comment.new(@con,"SP-3",12345)
    stub_request(:get, "http://test:1234@localhost:2990/jira/rest/api/2/issue/SP-3/comment/12345").with(:headers => {'Accept'=>'*/*', 'Content-Type'=>'application/json;charset=UTF-8', 'User-Agent'=>'Ruby'}).to_return(:status => 404, :body => '{"errorMessages":["Can not find a comment for the id: 12345."],"errors":{}}', :headers => {})
    assert_raises(Jirarest2::NotFoundError) {
      comment.get()
    }
  end


  def test__get_special_comment_success
    comment = Comment.new(@con,"SP-3",10109)
    stub_request(:get, "http://test:1234@localhost:2990/jira/rest/api/2/issue/SP-3/comment/10109").with(:headers => {'Accept'=>'*/*', 'Content-Type'=>'application/json;charset=UTF-8', 'User-Agent'=>'Ruby'}).to_return(:status => 200, :body => '{"self":"http://localhost:2990/jira/rest/api/2/issue/10104/comment/10109","id":"10109","author":{"self":"http://localhost:2990/jira/rest/api/2/user?username=test","name":"test","emailAddress":"jira-test@localhost","avatarUrls":{"16x16":"http://localhost:2990/jira/secure/useravatar?size=small&avatarId=10122","48x48":"http://localhost:2990/jira/secure/useravatar?avatarId=10122"},"displayName":"Test User","active":true},"body":"Text for the long run","updateAuthor":{"self":"http://localhost:2990/jira/rest/api/2/user?username=test","name":"test","emailAddress":"jira-test@localhost","avatarUrls":{"16x16":"http://localhost:2990/jira/secure/useravatar?size=small&avatarId=10122","48x48":"http://localhost:2990/jira/secure/useravatar?avatarId=10122"},"displayName":"Test User","active":true},"created":"2012-07-27T20:36:07.651+0200","updated":"2012-07-27T20:36:07.651+0200"}', :headers => {})
    result = comment.get
    assert_equal "Text for the long run", result[0].text
    assert_equal "Test User", result[0].author
    assert_instance_of CommentElement, result[0]
    assert_instance_of Time, result[0].mdate
  end


  def test_replace_comment
    comment = Comment.new(@con,"SP-3",10210)
    stub_request(:put, "http://test:1234@localhost:2990/jira/rest/api/2/issue/SP-3/comment/10210").with(:body => "{\"body\":\"New Comment\"}",:headers => {'Accept'=>'*/*', 'Content-Type'=>'application/json;charset=UTF-8', 'User-Agent'=>'Ruby'}).to_return(:status => 200, :body => '{"self":"http://localhost:2990/jira/rest/api/2/issue/10104/comment/10210","id":"10210","author":{"self":"http://localhost:2990/jira/rest/api/2/user?username=test","name":"test","emailAddress":"jira-test@localhost","avatarUrls":{"16x16":"http://localhost:2990/jira/secure/useravatar?size=small&avatarId=10122","48x48":"http://localhost:2990/jira/secure/useravatar?avatarId=10122"},"displayName":"Test User","active":true},"body":"New Comment","updateAuthor":{"self":"http://localhost:2990/jira/rest/api/2/user?username=test","name":"test","emailAddress":"jira-test@localhost","avatarUrls":{"16x16":"http://localhost:2990/jira/secure/useravatar?size=small&avatarId=10122","48x48":"http://localhost:2990/jira/secure/useravatar?avatarId=10122"},"displayName":"Test User","active":true},"created":"2012-07-29T17:31:32.230+0200","updated":"2012-07-29T18:06:22.943+0200"}', :headers => {})
    
    result = comment.update("New Comment")
    assert_equal "New Comment", result.text
    assert_equal "Test User", result.author
    assert_instance_of Time, result.mdate  

  end

  
  def test_delete_comment
    comment = Comment.new(@con,"SP-3",10208)
    stub_request(:delete, "http://test:1234@localhost:2990/jira/rest/api/2/issue/SP-3/comment/10208").with(:headers => {'Accept'=>'*/*', 'Content-Type'=>'application/json;charset=UTF-8', 'User-Agent'=>'Ruby'}).to_return(:status => 204 )
    assert_equal "204", comment.delete.code
  end

end # class
