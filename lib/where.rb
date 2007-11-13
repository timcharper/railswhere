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
  def initialize(criteria=nil, *params, &block)
    @clauses=Array.new
    
    self.and(criteria, *params) unless criteria.nil?
    
    yield(self) if block_given?
  end
  
  def initialize_copy(from)
    @clauses = from.instance_variable_get("@clauses").clone
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
  def and(*params, &block)
    append_clause(params, "AND", &block)
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
  def or(*params, &block)
    append_clause(params, "OR", &block)
  end
  
  # Same as or, but negates the whole expression
  def or_not(*params, &block)
    append_clause(params, "OR NOT", &block)
  end
  
  # Same as and, but negates the whole expression
  def and_not(*params, &block)
    append_clause(params, "AND NOT", &block)
  end
  
  def &(params)
    self.and(*params)
  end
  
  def |(params)
    self.or(*params)
  end
  
  def self.&(params)
    Where.new(*params)
  end
  
  def self.|(params)
    Where.new.or(*params)
  end
  
  # Converts the where clause to a SQL string.
  def to_s(format=nil)
    output=""
    
    @clauses.each_index{|index|
      omit_conjuction = (index==0)
      output << @clauses[index].to_s(omit_conjuction)  # Omit the clause if index=0
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
   
protected  
  def append_clause(params, conjuction = "AND", &block) # :nodoc:
    if block_given?
      yield(w = Where.new)
      @clauses << Clause.new(w, conjuction)
    else
      @clauses << Clause.new(params, conjuction) unless params.first.blank?
    end
    self
  end
  
  # Used internally to +Where+.   You shouldn't have any reason to interact with this class. 
  class Clause 
    
    def initialize(criteria, conjuction = "AND") # :nodoc:
      @conjuction=conjuction.upcase
      criteria = criteria.first if criteria.class==Array && criteria.length==1
        
      if criteria.class==Array   # if it's an array, sanitize it
        @criteria = ActiveRecord::Base.send(:sanitize_sql, criteria)
      else
        @criteria = criteria.to_s   # otherwise, run to_s.  If it's a recursive Where clause, it will return the sql we need
      end
    end
    
    def to_s(omit_conjuction=false) # :nodoc:
      if omit_conjuction
        output = @conjuction.include?("NOT") ? "NOT " : ""
        output << "(#{@criteria})"
      else
        " #{@conjuction} (#{@criteria})"
      end
    end
  end
end

def Where(*params, &block)
  Where.new(*params, &block)
end