=begin AFFERO_3
rapidito. Wiki database.
Copyright (C) 2009 Aureliano Calvo.

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU Affero General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
=end

class String
  alias_method :old_rapidito_upcase, :upcase
  def upcase
    self.gsub( /\303[\240-\277]/ ) do
      |match|
      match[0].chr + (match[1] - 040).chr
    end.old_rapidito_upcase
  end
  
  alias_method :old_rapidito_downcase, :downcase
  def downcase
    self.gsub( /\303[\200-\237]/ ) do
      |match|
      match[0].chr + (match[1] + 040).chr
    end.old_rapidito_downcase
  end
end

class Regexp
  alias_method :old_rapidito_inspect, :inspect
  
  def inspect
    @inspect ||= old_rapidito_inspect
  end
  
  def eql?( other )
    false if other.class != Regexp
    self.inspect == other.inspect
  end
  
  alias_method :"==", :eql?
  
  def hash
    self.inspect.hash
  end
end