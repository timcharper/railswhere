require File.join(File.dirname(__FILE__), '../spec_helper.rb')

describe Where do
  it "where_new__block__should_yield" do
    Where.new {|w| w.and("hi = ?", "1")}.to_s.should == "(hi = '1')"
  end
  
  it "where_or_block__should_work" do
    where = Where.new {|w| 
      w.or {
        w.or "x = ?", 1
        w.or "x = ?", 2
      }
      
      w.or {
        w.or "y = ?", 1
        w.or "y = ?", 2
      }
    }.to_s
    
    where.to_s.should == "((x = 1) OR (x = 2)) OR ((y = 1) OR (y = 2))"
  end
  
  it "where_and_block__should_work" do
    where = Where.new {|w| 
      w.and {
        w.or "x = ?", 1
        w.or "x = ?", 2
      }
      
      w.and {
        w.or "y = ?", 1
        w.or "y = ?", 2
      }
    }.to_s
    
    where.to_s.should == "((x = 1) OR (x = 2)) AND ((y = 1) OR (y = 2))"
  end
  
  it "where__and_not__no_perfix__should_work" do
    w = Where.new
    
    w.and_not { w.or("x = ?", 1).or("x = ?", 2) }
    
    w.to_s.should == "NOT ((x = 1) OR (x = 2))"
  end
  
  
  it "where__and_not__with_prefix__should_work" do
    w = Where.new
    
    w.and_not "x = ?", 1
    w.and_not "y = ?", 1
    
    w.to_s.should == "NOT (x = 1) AND NOT (y = 1)"
  end
  
  it "where__or_not__no_perfix__should_work" do
    w = Where.new
    
    w.or_not{ w.or("x = ?", 1).or("x = ?", 2) }
    
    w.to_s.should == "NOT ((x = 1) OR (x = 2))"
  end
  
  
  it "where__or_not__with_prefix__should_work" do
    w = Where.new
    
    w.or_not "x = ?", 1
    w.or_not "y = ?", 1
    
    w.to_s.should == "NOT (x = 1) OR NOT (y = 1)"
  end
  
  
  it "where_new_chained_or" do
    Where.new("x=1").or("x=2").to_sql.should == "(x=1) OR (x=2)"
  end
  
  it "where_new_chained_and" do
    Where.new("x=1").and("x=2").to_sql.should == "(x=1) AND (x=2)"
  end
  
  it "where_and_where" do
    where = Where.new
    where.and Where.new("x=1")
    where.to_s.should == "((x=1))"
  end
  
  it "where_or_where" do
    where = Where.new
    where.or Where.new("x=1")
    where.to_s.should == "((x=1))"
  end
  
  it "where_method_invocation" do
    Where{|w| w & ["x=?", 1] }.to_s.should == "(x=1)"
  end
  
  it "should nest clauses" do
    w = Where.new
    w.and { 
      w.or "x = 1"
      w.or "x = 2"
    }
    w.and "y = 1"
    w.to_sql.should == "((x = 1) OR (x = 2)) AND (y = 1)"
  end
  
  it "should use default params when rendering sql" do
    where = Where.new(:default_params => {:x => 1})
    where.default_params.should == {:x => 1}
    where.and("x = :x")
    where.to_s.should == "(x = 1)"
  end
  
  it "should return a valid clause when the where clause is empty" do
    Where.new.to_s.should == "(true)"
  end
end