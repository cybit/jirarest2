# IssueLink class
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

require_relative "../connect"
require_relative "../services"
require_relative "../issue"
require_relative "issuelinktype"
require_relative "../exceptions"

#  This class is responsible for the Linking of Issues
#  No real getter as of yet (I just didn't need it)
class IssueLink < Services

  def initialize(connection)
    @uritail = "issueLink"
    super(connection)
    @linktype = IssueLinkType.new(@connection)
  end

  private

  # return the issuekey regardless whether we got an Issue or just the Key
  # @param [String, Issue] issue
  # @return [String]
  def key(issue)
    if issue.instance_of?(Issue) then
      return issue.issuekey 
    else 
      return issue
    end
  end
  
  public
  
  #Show the possible answers for the issuelinktypes
  # @return String
  def valid_issuelinktypes(delimiter = ", ")
    return @linktype.valid_names(delimiter)
  end

  # Links two issues
  # Right now the visibility feature for comments is not supported
  # @param [String, Issue] thisIssue Issue to connect from
  # @param [String, Issue] remoteIssue Issue to connect to
  # @param [String] type Link type
  # @param [String] comment If a comment should be set while linking
  # @return [Jirarest2::Result] The result of the linking
  def link_issue(thisIssue,remoteIssue,type,comment = nil)
    inwardIssue = key(thisIssue)
    outwardIssue = key(remoteIssue)
    
    # lets see if we have the right name
    if ! @linktype.internal_name?(type) then # time to find the correct name and see if we have to exchange tickets
      realname = @linktype.name(type)
      if realname.nil? then
        raise Jirarest2::ValueNotAllowedException.new(type,valid_issuelinktypes), type 
      else
        type = realname[0]
        if realname[1] == "inward" then # we have to change the issues as jira only knows one direction.
          temp = inwardIssue
          inwardIssue = outwardIssue
          outwardIssue = temp
        end
      end
    end # if ! linktype.internal_name?
    
    
    #create the hashes for JSON
    json = Hash.new
    json["type"] = { "name" => type }
    json["inwardIssue"] = { "key" => inwardIssue }
    json["outwardIssue"] = { "key" => outwardIssue }
    json["comment"] = { "body" => comment}     if comment
    return post(json)
  end

  # does the linking ig you don't want to bother with the exact result
  # @param [String, Issue] thisIssue Issue to connect from
  # @param [String, Issue] remoteIssue Issue to connect to
  # @param [String] type Link type
  # @param [String] comment If a comment should be set while linking
  # @return [Boolean] Only true if successfully linked false if something happened. Elseway exactly as link_issue.
  def link(thisIssue,remoteIssue,type,comment = nil)
    if link_issue(thisIssue,remoteIssue,type,comment).code == "201" then
      return true
    else
      return false
    end
  end
  
end # class
