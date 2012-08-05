# This files only purpose is to have one place to control all debugging information

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


if ENV['DEBUG'] then
  require "pp"
  # Version of pp that will result in errors if the environment Variable "DEBUG" is not set.
  # A way to find forgotten debug info before shipping?
  def ppp(data)
    pp data
  end
end
