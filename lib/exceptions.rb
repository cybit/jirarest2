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


module Jirarest2
  ## connections.rb
  class AuthentificationError < StandardError ; end
  class AuthentificationCaptchaError < StandardError ; end
  ## credentials.rb
  class NotAnURLError < ArgumentError ; end
  ## issue.rb
  class  WrongProjectException < ArgumentError; end
  class WrongIssuetypeException < ArgumentError; end
  class WrongFieldnameException < ArgumentError; end
  class ValueNotAllowedException < ArgumentError; end
  class RequiredFieldNotSetException < ArgumentError; end

end
