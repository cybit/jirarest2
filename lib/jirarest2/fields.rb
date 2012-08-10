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

require_relative "fields/multifields"
require_relative "fields/simplevaluefield"
require_relative "fields/simplekeyfield"
require_relative "fields/simplenamefield"
require_relative "fields/timefield"
require_relative "fields/cascadingfield"

module Jirarest2
  # Superclass for all fieldtypes we will get from jira
  class Fields
    # Type of the field at the root of the JSON representation
    attr_reader :roottype
    # Type of the field at the base of the representation
    attr_reader :basetype
    def initialize
    end
  end
end
