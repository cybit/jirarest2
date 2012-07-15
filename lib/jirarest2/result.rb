# Our own class to hide the use of Net::HTTP and uri in the results we get


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

require 'json'

module Jirarest2
=begin
  An object of Result contians the result of a Net::HTTP REST request that has a JSON-Body with easily accessable parameters.
=end
class Result

  # The statuscode of the result
  attr_reader :code
  # header lines
  attr_reader :header
  # The original body of the result
  attr_reader :body
  # The JSON part of the body
  attr_reader :result

=begin
 Takes an Net::HTTPResponse object and builds itself from there
=end
 def initialize(httpResponse)
#   pp httpResponse
#   pp httpResponse.body
   @code = httpResponse.code
   @header = httpResponse.to_hash
   @body = httpResponse.body
   if httpResponse.instance_of?(Net::HTTPNoContent) or httpResponse.body == "" then # If there is nothing in the body it would be hard to parse it.
     @result = @body
   else
     @result = JSON.parse(@body)
   end
 end # initialize

end # class

end # module
