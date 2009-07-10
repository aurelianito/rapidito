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