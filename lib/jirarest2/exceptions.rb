# module to handle all the exceptions in their own namespace
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

# Keep all the Exceptions in their own module
module Jirarest2
  ## connections.rb

  # 400 - 
  class BadRequestError < StandardError ; end
  # 401 Authentification failed 
  class AuthentificationError < StandardError ; end
  # 403 Authentification failed and JIRA(tm) requires a login with captcha to continue
  class AuthentificationCaptchaError < StandardError ; end
  # 403 Authentification failed
  class ForbiddenError < StandardError ; end
  # 404 - Results in HTML body - not JSON
  class NotFoundError < StandardError ; end
  # 405 - Method not allowed
  class MethodNotAllowedError < StandardError ; end
  # Could not heal URI
  class CouldNotHealURIError < StandardError ; end
  

  ## credentials.rb

  # String given as an URI isn't one
  class NotAnURLError < ArgumentError ; end

  ## issue.rb

  # Project does not exist in the given JIRA(tm) instance
  class  WrongProjectException < ArgumentError; end
  # Issue type does not exist in the given project
  class WrongIssuetypeException < ArgumentError; end
  # There is no field with this name for the given issue type
  class WrongFieldnameException < ArgumentError; end
  # value is not allowed for this type of fields
  class ValueNotAllowedException < ArgumentError
    # The name of the field the value does not match to
    attr_reader :fieldname
    # Matching values
    attr_reader :allowed
    
    def initialize(fieldname,allowed)
      @fieldname = fieldname
      @allowed = allowed
    end
  end
  # A field that is defined as "required" has not been given a value
  class RequiredFieldNotSetException < ArgumentError; end

end
