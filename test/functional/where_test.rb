require File.join(File.dirname(__FILE__), '../test_helper.rb')

class WhereTest < Test::Unit::TestCase
  def test__where_new__block__should_yield
    assert_equal("(hi = '1')", Where.new {|w| w.and("hi = ?", "1")}.to_s)
  end
  
  def test__where_or_block__should_work
    where = Where.new {|w| 
      w.or {|y|
        y.or "x = ?", 1
        y.or "x = ?", 2
      }
      
      w.or {|y|
        y.or "y = ?", 1
        y.or "y = ?", 2
      }
    }.to_s
    
    assert_equal("((x = 1) OR (x = 2)) OR ((y = 1) OR (y = 2))", where.to_s)
  end
  
  def test__where_and_block__should_work
    where = Where.new {|w| 
      w.and {|y|
        y.or "x = ?", 1
        y.or "x = ?", 2
      }
      
      w.and {|y|
        y.or "y = ?", 1
        y.or "y = ?", 2
      }
    }.to_s
    
    assert_equal("((x = 1) OR (x = 2)) AND ((y = 1) OR (y = 2))", where.to_s)
  end
  
  def test__where_new_chained_or
    assert_equal("(x=1) OR (x=2)", Where.new("x=1").or("x=2").to_sql)
  end
  
  def test__where_new_chained_and
    assert_equal("(x=1) AND (x=2)", Where.new("x=1").and("x=2").to_sql)
  end
end