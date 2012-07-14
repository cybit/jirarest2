# Module to handle configuration files
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

=begin
 Module to handle configuration files
=end
module Config
=begin
 Inspired by http://www.erickcantwell.com/2011/01/simple-configuration-file-reading-with-ruby/
 reads a config-file and returns a hash
=end
  def self.read_configfile(config_file)
    config_file = File.expand_path(config_file)

    unless File.exists?(config_file) then
      raise "Unable to find config file"
    end
    
    regexp = Regexp.new(/\s+|"|\[|\]/)
    
    temp = Array.new
    vars = Hash.new
    
    IO.foreach(config_file) { |line|
      if line.match(/^\s*#/) #  don't care about lines starting with an # (even after whitespace)
        next
      elsif line.match(/^\s*$/) # no text, no content
        next
      else
# Right now I don't know what to use scan for. It will escape " nice enough. But once that is excaped the regexp doesn't work any longer.
#        temp[0],temp[1] = line.to_s.scan(/^.*$/).to_s.split("=")
        temp[0],temp[1] = line.to_s.split("=")
        temp.collect! { |val|
          val.gsub(regexp, "")
        }
        vars[temp[0]] = temp[1]
      end
    }
    return vars
  end
end
