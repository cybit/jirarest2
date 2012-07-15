#!/usr/bin/env ruby

# Script to create a new issue with jira.
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



if RUBY_VERSION < "1.9"
  puts "Sorry, I need ruby 1.9.1 or higher!"
  exit1
end

require "highline/import"
require "jirarest2"
require "optparse"
require "ostruct"
require "config"
require "uri"
require "pp"

class ParseOptions

  def self.required_argument(name)
    puts "Argument \"#{name}\" is mandatory."
    exit 1
  end

=begin
  parse resturn two Hashes. The first one contains the options for the issue the second one the options for the execution of the script.
=end
  def self.parse(args)
    issueopts = OpenStruct.new
    issueopts.project = nil
    issueopts.issue = nil
    scriptopts = OpenStruct.new
    scriptopts.show = []
    scriptopts.arrayseperator = "|"
    scriptopts.configfile = "~/.jiraconfig"
    
    opts = OptionParser.new do |opts|
      opts.banner = "Usage: #{__FILE__} [options]"
      opts.separator ""
      
      opts.on("-p", "--project PROJECT", "Projectname") do |p|
        issueopts.project = p
        issueopts
      end
      
      opts.on("-i", "--issue ISSUETYPE", "Issuetype") do |i|
        issueopts.issue = i
      end
      
      opts.on("-f", "--fields", "Display the fields available for this issue") do |f|
        scriptopts.show << "fields"
      end
      
      opts.on("-r", "--requireds", "Display the the mandatory content fields for this issue") do |r|
        scriptopts.show << "requireds"
      end
      
      opts.on("-c", "--content x:value,y:value,z:value", Array, "List of fields to fill") do |list|
        issueopts.content = list
      end
      
      opts.on("-w", "--watcher USERNAME,USERNAME", Array, "List of watchers") do |w|
        issueopts.watchers = w
      end
      
      opts.on("-F", "--field-seperator CHAR", "A fieldseperator if one of the fields is an array (Default \"|\")") do |fs|
        scriptopts.arrayseperator = fs
      end

      
      opts.on("--config-file CONFIGFILE", "Config file containing the jira credentials. (Default: ~/.jiraconfig)") do |conffile|
        scriptopts.configfile = conffile
      end

      opts.on("-u", "--username USERNAME", "Your Jira Username if you don't want to use the one in the master file") do |u|
        scriptopts.username = u 
      end
      
      opts.on("-H", "--jira-url URL", "URL to connect to jira in the browser") do |url|
        uri = URI(URL)
        scriptopts.url = uri.schme + "://" + uri.host + uri.port
      end

      opts.on_tail("-h", "--help", "Display this screen") do
        puts opts
        exit
      end
      
      opts.on_tail("--version", "Show version") do
        puts OptionParser::Version.join(".")
        exit
      end
    end
    
  
    opts.parse!(args)

    if issueopts.project.nil? then
      required_argument("project")      
    end
    if issueopts.issue.nil? then
      required_argument("issue")
    end
    return issueopts, scriptopts
  end #parse()


end # class ParseOptions

@issueopts, @scriptopts = ParseOptions.parse(ARGV)




def no_issue(type,issue)
  puts "The #{type}type you entered (\"#{issue}\")  does no exist."
    puts "Maybe you entered the wrong type or made a typo? (Case is relevant!)"
    exit 1
end

def get_password
  ask("Enter your password for user \"#{@scriptopts.username}\":  ") { |q| q.echo = "*" }
end

=begin
  Gather all the credentials and build the credentials file
=end
def get_credentials
  fileconf = Config::read_configfile(@scriptopts.configfile)
  # We don't want to set the calues from the configfile if we have them already set.
  @scriptopts.username = fileconf["username"] if ( @scriptopts.username.nil? && fileconf["username"] )
  @scriptopts.pass = fileconf["password"] if ( @scriptopts.pass.nil? && fileconf["password"] )
  if ( @scriptopts.url.nil? && fileconf["URL"] ) then
    @scriptopts.url = fileconf["URL"] 
    @scriptopts.url = @scriptopts.url + "/jira/rest/api/2/"
  end
  if @scriptopts.pass.nil? then
    @scriptopts.pass = get_password
  end
  
  return Credentials.new(@scriptopts.url, @scriptopts.username, @scriptopts.pass)
end

=begin
 create the issue on our side
=end
def open_issue
  begin
    credentials = get_credentials
    issue=Issue.new(@issueopts.project,@issueopts.issue,credentials)
    # issue=Issue.new(@issueopts.project,@issueopts.issue,@scriptopts.pass,@scriptopts.username)
  rescue Jirarest2::AuthentificationError => e
    puts "Password not accepted."
    @scriptopts.pass = get_password
    retry
  rescue Jirarest2::AuthentificationCaptchaError => e
    puts "Wrong Password too many times.\nCaptcha time at #{e.to_s} to reenable your account."
    exit 1
  rescue Jirarest2::WrongProjectException => e
    no_issue("project",e)
  rescue Jirarest2::WrongIssuetypeException => e
    no_issue("project",e)
  end
  return issue
end

def show_scheme
  issue = open_issue
  if @scriptopts.show.include?("fields") then
    print "Available fields: "
    puts issue.get_fieldnames.join(", ")
  end
  if @scriptopts.show.include?("requireds") then
    print "Required fields: "
    puts issue.get_requireds.join(", ")
  end
  exit
end


def prepare_new_ticket
  issue = open_issue
  valueNotAllowedRaised = false
  @issueopts.content.each { |value|
    split = value.split(":")
    begin
      if issue.fieldtype(split[0]) == "array" then # If the fieldtype is an array we want to use our arrayseparator to split the fields
        if ! split[1].nil? then 
          split[1] = split[1].split(@scriptopts.arrayseperator)
        end
      end
      issue.set_field(split[0],split[1])
    rescue Jirarest2::WrongFieldnameException => e
      no_issue("field",e)
    rescue Jirarest2::ValueNotAllowedException => e
      puts "Value #{split[1]} not allowed for field #{split[0]}."
      puts "Please use one of: \"" + e.message.join("\", \"") + "\""
      valueNotAllowedRaised = true
    end
  }
  if valueNotAllowedRaised then
    raise Jirarest2::ValueNotAllowedException
  end
  return issue
end

def set_watchers(issue)
  issue.set_watcher(credentials,@issueopts.watchers)
end

def create_new_ticket(issue)
  begin
    result = issue.persist(get_credentials).result
    # Set the watchers
    if @issueopts.watchers then
      watcherssuccess = issue.add_watchers(get_credentials,@issueopts.watchers)
    end
  rescue Jirarest2::RequiredFieldNotSetException => e
    puts "Required field \"#{e.to_s}\" not set."
    return 1
  end
  if result["key"] then
    puts "Created new issue with issue id #{result["key"]} ."
    if ! watcherssuccess then
      puts "Watchers could not be set though."
    end
    return 0
  elsif result["errors"] then
    puts "An error occured. The error message was: #{result["errors"].to_s}"
    return 2
  end
end


# The "main function"
if @scriptopts.show != [] then
  show_scheme
end
if ! @issueopts.content.nil? then # If the -c option is set. (-c and no content leads to another exception)
  content = prepare_new_ticket
  pp @issueopts.watchers
  exit create_new_ticket(content)
end

