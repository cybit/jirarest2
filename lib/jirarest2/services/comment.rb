# Comment class
#    Copyright (C) 2012 Cyril Bitterich
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.
#

require "time"
require "jirarest2/connect"
require "jirarest2/services"

#TODO give nicer answers in return to work

# One single Comment
# TODO Maybe rewrite the initalize and then get a few other parameters like the issue-id or the comment-id
class CommentElement 
  #The author of the comment
  # @return [String]
  attr_reader :author
  #text of the comment
  # @return [String]
  attr_reader :text
  #creation date
  # @return [Time]
  attr_reader :cdate
  #last modify date
  # @return [Time]
  attr_reader :mdate

  # create one instance of an Comment
  # @param [String] author (Last) author of the comment
  # @param [String] text Text of the comment
  # @param [Time,String] cdate Creation date of the comment
  # @param [Time,String] mdate Date of last change to the comment
  def  initialize(author,text,cdate = Time.now,mdate = Time.now)
    @author = author
    @text = text
    #  parse time if needed
    cdate = Time.parse(cdate) if cdate.instance_of?(String)
    @cdate = cdate
    mdate = Time.parse(mdate) if mdate.instance_of?(String)
    @mdate = mdate
  end
end

class Comment < Services
#TODO See to documentation for "DELETE" as we use the superclass here and it will not be shown

  #  Set our uritail
  # @param [Connection] connection 
  # @param [String] issueid The id or key of the issue in question
  def initialize(connection, issueid, commentid = nil)
    if commentid then
      @uritail = "issue/#{issueid}/comment/#{commentid}"
    else
      @uritail = "issue/#{issueid}/comment"
    end
    super(connection)
  end

  # Add a comment to an issue
  # @param [String] text to add
  # @return [Result] The result as constructed by Connection.execute
  def add(text)
    post({"body" => text})
  end

  # Split the returned hash and fill the CommentElement
  # @param [Hash] result The json based hash of one Comment
  # @return [CommentElement] One comment
  private
  def create_element(result)
    text = result["body"]
    author = result["updateAuthor"]["displayName"]
    ctime = result["created"]
    mtime = result["updated"]
    return CommentElement.new(author,text,ctime,mtime)          
  end

  public
  # Get a certain comment
  # @param [String] data Additional data to send via GET
  # @return [Nil] If there is no comment in the Project
  # @return [Array(CommentElement)] If there is one or more than one result - TODO See if this is going to be changed for a special type that keeps startAt, maxResults and total
  def get(data = "")
    result = super("")
    if result["comments"].nil? then
      return [create_element(result)]
    elsif result["comments"].empty? then
      return nil
    else
      resultarray = Array.new
      result["comments"].each { |singleresult|
         resultarray << create_element(singleresult)
      }
      return resultarray
    end
  end
  
  # Update an comment
  # @param [String] text The new text for the comment
  # @return [CommentElement] The new comment
  def update(text)
    result =  put({"body" => text})
    return CommentElement.new(result["updateAuthor"]["displayName"], result["body"], result["created"], result["updated"])
  end
    
end # Comment
