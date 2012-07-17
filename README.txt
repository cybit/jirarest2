= jirarest2

* https://github.com/cybit/jirarest2#readme

== DESCRIPTION:

jirarest2 is yet another implementation of the JIRA(tm) REST-API[https://developer.atlassian.com/display/JIRADEV/JIRA+Remote+API+Reference] .  This one for Ruby1.9.1

It is intended to be called within the shell to create and verify JIRA(tm) issues fast without a browser. There was no particular need for perfomance at the time of writing.

This implementation is still a for cry from others like http://rubygems.org/gems/jira-ruby which required oauth authentification. 

The script allows you to create new issues with watchers and link those to existing issues

 *Use it at your own risk. Most of the API features are not implemented.*

 *Ruby1.9.1 is needed. Ruby1.8 doesn't work!*


== FEATURES/PROBLEMS:

   * Still in the very first alpha stages. The classes are still pretty volatile.
   * The script allows you to create new issues with watchers and link those to existing issues

== SYNOPSIS:

jira_create_issue -h

== REQUIREMENTS:

 * json
 * highline

== INSTALL:

sudo gem install jirarest2

== DEVELOPERS:

Cyril Bitterich

== LICENSE:

(GPLv3)

Copyright (c) 2012 Cyril Bitterich

    
    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.

