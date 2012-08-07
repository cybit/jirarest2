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

# Module to handle configuration files
module MadbitConfig

require "json"

# Special exception to make the point why we threw it around
  class FileExistsException < IOError ; end
  

# Inspired by http://www.erickcantwell.com/2011/01/simple-configuration-file-reading-with-ruby/

  # reads a config-file and returns a hash
  # The config file can either contain key = value pairs or JSON data
  # JSON and simple "key = value\n" lines work 
  # TODO make it work with "key = [value,value]\n" or even "key = value1 \n value2 \n ..."
  # @param [String] configfile
  # @param [Boolean] whitespace Keep whitespace characters? 
  # @return [Hash] Hash configparameters
  def self.read_configfile(config_file,whitespace = false)
    if whitespace then    
      regexp = Regexp.new(/"|\[|\]/)
    else
      regexp = Regexp.new(/\s+|"|\[|\]/)
    end
    
    temp = Array.new
    vars = Hash.new
    file = String.new

    if config_file == "-" then
      # caller wants STDIN
      file = ARGF.read
    else
      # caller wants real file
      config_file = File.expand_path(config_file)
      unless File.exists?(config_file) then
        raise IOError, "Unable to find config file \"#{config_file}\""
      end
      file = IO.read(config_file)
    end
    if file =~ /^\s*{/ then
      vars = JSON.parse(file)
    else
      file.each_line { |line|
        if line.match(/^\s*#/) #  don't care about lines starting with an # (even after whitespace)
          next
        elsif line.match(/^\s*$/) # no text, no content
          next
        else
          # Right now I don't know what to use scan for. It will escape " nice enough. But once that is excaped the regexp doesn't work any longer.
          temp[0],temp[1] = line.to_s.scan(/^.*$/).to_s.split("=")
          #temp[0],temp[1] = line.to_s.split("=")
          temp.collect! { |val|
            val.gsub(regexp, "")
          }
          vars[temp[0]] = temp[1]
        end
      }
    end # JSON or not?
    return vars
  end # read.configfile
  
  
  # write a configfile
  # @param [String] config_file Name (and path) of the config file
  # @param [Hash] configoptions Hash of "option" => "value" pairs
  # @param [Symbol] save Determines if an existing file is to be kept. :force replaces an existing file
  def self.write_configfile(config_file, configoptions, save = :noforce)
    config_file = File.expand_path(config_file) # Be save
    
    # First we make sure we don't overwrite a file if the save - flag is set.
    if save != :force then
      if File.exists?(config_file) then
        raise FileExistsException, config_file
      end
    end
    # write the file
    File.open(config_file, File::CREAT|File::TRUNC|File::RDWR,0600) { |f|
      configoptions.each { |option,value|
        f.write( option + " = " + value  + "\n")
      }
    } # File
  end # write_configfile

end # module
