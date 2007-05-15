# = Where clause generator
# == Author: Tim Harper ( "timseeharperATgmail.seeom".gsub("see", "c").gsub("AT", "@") )
#
# <b>Usage example</b>
# === Returning SQL
#
#  sql = Where.new('x=?',5).and( Where.new('x=?',6).or('x=?',7)).to_s
#  # returns (x=5) and ( ( x=6 ) or ( x=7 ) ) 
#  
# === Building a complicated where clause made easy
#  
#  def get_search_query_string
#  
#    where = Where.new
#    where.and('users.first_name like ?', params[:search_first_name] + '%') unless params[:search_first_name].blank?
#    where.and('users.last_name like ?', params[:search_last_name] + '%') unless params[:search_last_name].blank?
#  
#    status_where = Where.new
#    for status in params[search_statuses].split(',')
#      status_where.or 'status=?', status
#    end
#    where.and status_where unless status_where.blank?
#  
#    where.to_s
#  end
#  
# User.find(:all, :conditions => get_search_query_string)
#  
# ===  Inline
#  
#    User.find(:all, :conditions => Where.new('first_name like ?', 'Tim').and('last_name like ?', 'Harper') )


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
