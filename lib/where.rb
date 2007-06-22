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
#    # Sweet chaining action!


class Where
  
  # Constructs a new where clause
  # 
  # optionally, you can provide a criteria, like the following:
  #   
  #   Where.initialize "joke_title = ?", "He says, 'Under there', to which I reply, 'under where?'"
  def initialize(criteria=nil, *params)
    @clauses=Array.new
    
    self.and(criteria, *params) unless criteria.nil?
  end
  
  # Appends an <b>and</b> expression to your where clause
  # 
  # Example:
  #   
  #   where = Where.new
  #   where.and("name = ?", "Tim O'brien")
  #   where.to_s
  #   
  #   # => "(name = 'Tim O''brien')
  def and(criteria, *params)
    criteria = [criteria] + params unless params.empty?
    @clauses << Clause.new(criteria) unless criteria.blank?
    self
  end
  
  alias << and
  
  # Appends an <b>or</b> expression to your where clause
  # 
  # Example:
  #   
  #   where = Where.new
  #   where.or("name = ?", "Tim O'brien")
  #   where.or("name = ?", "Tim O'neal")
  #   where.to_s
  #   
  #   # => "(name = 'Tim O''brien') or (name = 'Tim O''neal')"
  def or(criteria, *params)
    criteria = [criteria] + params unless params.empty?
    @clauses << Clause.new(criteria, true) unless criteria.blank?
    self
  end
  
  # Converts the where clause to a SQL string.
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
      output.empty? ? nil : output
    end
  end
  
  alias :to_sql :to_s
  
  # Determines if any clauses have been added.
  # 
  #   where = Where.new
  #   where.blank?
  #   # => true
  #   
  #   where.and(nil)
  #   where.blank?
  #   # => true
  #   
  #   where.and(Where.new(nil))
  #   where.blank?
  #   # => true
  #   
  #   where.and("name=1")
  #   where.blank?
  #   # => false
  def blank?
    @clauses.empty?
  end
  
  alias :empty? :blank? 
   
  # Used internally to +Where+.   You shouldn't have any reason to interact with this class. 
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
