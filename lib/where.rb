# Where clause generator
# Copyright Tim Harper
# Usage example
# sql = Where.new(['x=?',5]).or( Where.new('x=5').or('x=7')).to_s
# 
# 
#

class Where
  def initialize(criteria=nil, *params)
    @clauses=Array.new
    
    self.and(criteria, *params) unless criteria.nil?
  end
  
  def and(criteria, *params)
    criteria = [criteria] + params unless params.empty?
    @clauses << Clause.new(criteria) unless criteria.blank?
    self
  end
  
  alias << and
  
  def or(criteria, *params)
    criteria = [criteria] + params unless params.empty?
    @clauses << Clause.new(criteria, true) unless criteria.blank?
    self
  end
  
  def to_s(format=nil)
    output=""
    
    @clauses.each_index{|index|
      omit_clause = (index==0)
      output << @clauses[index].to_s(omit_clause)  # Omit the clause if index=0
    }
    case format
    when :where
      output.empty? ? "" : " WHERE #{output}"
    else
      output
    end
  end
  
  def empty?
    @clauses.empty?
  end
  
  alias :blank? :empty?  
  class Clause
    def initialize(criteria, is_or = false)
      @is_or=is_or
      
      if criteria.class==Array      # if it's an array, sanitize it
        @criteria = ActiveRecord::Base.send(:sanitize_sql, criteria)
      else
        @criteria = criteria.to_s   # otherwise, run to_s.  If it's a recursive Where clause, it will return the sql we need
      end
    end
    
    def to_s(omit_clause=false)
      if omit_clause
        "(#{@criteria})"
      else
        " #{@is_or ? 'OR' : 'AND'} (#{@criteria})"
      end
    end
  end
end