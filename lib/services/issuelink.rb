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

require "connect"
require "services"
require "issue"
require "services/issuelinktype"
require "exceptions"

=begin
  This class is responsible for the Linking of Issues
  No real getter as of yet (I just didn't need it)
=end
class IssueLink < Services

  def initialize(connection)
    @uritail = "issueLink"
    super(connection)
  end

  private
=begin
 return the issuekey
=end
  def key(issue)
    if issue.instance_of?(Issue) then
      return issue.issuekey 
    else 
      return issue
    end
  end
  
  public
=begin
 Links two issues
 Right now the visibility feature for comments is not supported
=end
  def link_issue(thisIssue,remoteIssue,type,comment = nil)
    inwardIssue = key(thisIssue)
    outwardIssue = key(remoteIssue)
    
    # lets see if we have the right name
    linktype = IssueLinkType.new(@connection)
    if ! linktype.internal_name?(type) then # time to find the correct name and see if we have to exchange tickets
      realname = linktype.name(type)
      if realname.nil? then
        raise Jirarest2::ValueNotAllowedException, type 
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

=begin
 Only true if successfully linked false if something happened. Elseway exactly as link_issue.
=end
  def link(thisIssue,remoteIssue,type,comment = nil)
    if link_issue(thisIssue,remoteIssue,type,comment).code == "201" then
      return true
    else
      return false
    end
  end

end # class
