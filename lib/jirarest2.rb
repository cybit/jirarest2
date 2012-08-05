# Jirarest2 is a gem to connect to the REST interface of JIRA(tm) . It uses Basic authentication and not oauth


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

VERSION = "0.0.11"

require_relative "jirarest2/connect"
require_relative "jirarest2/issue"
require_relative "jirarest2/newissue"
require_relative "jirarest2/credentials"
require_relative "jirarest2/password_credentials"
require_relative "jirarest2/cookie_credentials"
require_relative "jirarest2/exceptions"
require_relative "jirarest2/services/watcher"
require_relative "jirarest2/services"
require_relative "jirarest2/services/issuelink"
require_relative "jirarest2/services/comment"
