= jirarest2

* https://github.com/cybit/jirarest2#readme

== DESCRIPTION:

jirarest2 is yet another implementation of the JIRA(tm) REST api ( https://developer.atlassian.com/display/JIRADEV/JIRA+Remote+API+Reference ). 
 It is intended to be called within the shell to create and verify JIRA(tm) issues fast without a browser.
 This implementation is still a for cry from others like http://rubygems.org/gems/jira-ruby which required oauth authentification. 
 Use it at your own risk most of the API features are not implemented.


== FEATURES/PROBLEMS:

Still in the very first alpha stages. You can only create new issues with watchers.

== SYNOPSIS:

create_issue -h

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

