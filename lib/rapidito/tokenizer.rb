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

module Rapidito
  class Tokenizer
  
    def initialize( *delimiters )
      @delimiter_list = delimiters +  [/\z/]
      @match_cache = nil
    end
    
    def source
      valid_cache? ? @match_cache[0].to_s + @source : @source
    end
    
    def source=(s)
      @match_cache = nil
      @source = s
    end
    
    def has_next?
      !@source.empty? || valid_cache?
    end
    
    def valid_cache?
      (!@match_cache.nil?) && (@match_cache[0].to_s.length > 0)
    end
    
    def next_match
      @delimiter_list.map {|regex| [regex.match(@source),regex]}.reject {|p| p[0].nil?}.inject do
        |better,new|
        better_pos = better[0].pre_match.length
        new_pos = new[0].pre_match.length
        
        if better_pos < new_pos
          better
        elsif new_pos < better_pos
          new
        elsif better[0].to_s.length > new[0].to_s.length
          better
        else
          new
        end
      end
    end
    
    def next_token
      if @match_cache #cached delimiter
        rv = @match_cache
        @match_cache = nil
        return rv
      end
      
      match = next_match
      p = match[0].pre_match.length
      @source = @source[p + match[0].to_s.length, @source.length]
      
      if p == 0 #delimiter
        match
      else #text
        @match_cache = match
        [match[0].pre_match, :text]
      end
    end
    
    def all_tokens
      tokens = []
      while has_next?
        tokens << next_token
      end
      tokens
    end
  end
end