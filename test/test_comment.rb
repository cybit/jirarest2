require "minitest/autorun"
require "webmock/minitest"
require "jirarest2/connect"
require "jirarest2/credentials"
require "jirarest2/services/comment"

class TestComment < MiniTest::Unit::TestCase
  def setup
    cred = Credentials.new("http://localhost:2990/jira/rest/api/2/","test","1234")
    @con = Connect.new(cred)
  end

=begin
  def test_get_comment_filled
    comment = Comment.new(@con,"SP-1")
#    TODO - here we actually want to get an 
    assert_instance_of Multianswer, comment.get
  end

  def test_get_comment_empty
    comment = Comment.new(@con,"SP-3")
    assert_equal "", comment.get
  end
=end

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
    stub_request(:post, "http://test:1234@localhost:2990/jira/rest/api/2/issue/SP-3/comment").with(:body => "{\"body\":\"Text for the long run\"}",:headers => {'Accept'=>'*/*', 'Content-Type'=>'application/json;charset=UTF-8', 'User-Agent'=>'Ruby'}).to_return(:status => 201, :body => '{"self":"http://localhost:2990/jira/rest/api/2/issue/10104/comment/10110","id":"10110","author":{"self":"http://localhost:2990/jira/rest/api/2/user?username=test","name":"test","emailAddress":"jira-test@madbit.de","avatarUrls":{"16x16":"http://localhost:2990/jira/secure/useravatar?size=small&avatarId=10122","48x48":"http://localhost:2990/jira/secure/useravatar?avatarId=10122"},"displayName":"Test User","active":true},"body":"Text for the long run","updateAuthor":{"self":"http://localhost:2990/jira/rest/api/2/user?username=test","name":"test","emailAddress":"jira-test@madbit.de","avatarUrls":{"16x16":"http://localhost:2990/jira/secure/useravatar?size=small&avatarId=10122","48x48":"http://localhost:2990/jira/secure/useravatar?avatarId=10122"},"displayName":"Test User","active":true},"created":"2012-07-27T20:36:07.832+0200","updated":"2012-07-27T20:36:07.832+0200"}', :headers => {})

    comment = Comment.new(@con,"SP-3")
    assert_match /,"body":"Text for the long run","updateAuthor"/, comment.add("Text for the long run").body
    assert_instance_of Jirarest2::Result, comment.add("Text for the long run")
  end

  def test_get_special_comment_fail
    comment = Comment.new(@con,"SP-3",12345)
    WebMock.disable!
    
    assert_raises(Jirarest2::NotFoundError) {
      comment.get()
    }
  end

=begin

  def test__get_special_comment_success
    comment = Comment.new(@con,"SP-3",10109)
    
  end

  def test_replace_comment
    comment = Comment.new(@con,"SP-3")
    
  end
  
  def test_delete_comment
    comment = Comment.new(@con,"SP-3")
    
  end
=end
end # class
