require File.join(File.dirname(__FILE__), '../spec_helper.rb')

describe Where do
  describe "#new" do
    it "yields the instance to the optional block, much like tap" do
      Where.new { |w| w.and("hi = ?", "1") }.to_s.should == "(hi = '1')"
    end
    
    it "sets default_params, which are used when params not provided" do
      where = Where.new(:default_params => {:x => 1})
      where.default_params.should == {:x => 1}
      where.and("x = :x")
      where.to_s.should == "(x = 1)"
    end
  end

  describe "#or" do
    it "appends or conditions, parenthetically grouped by statements inside of blocks" do
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
    
    it "returns the where object so that it can be daisy chained" do
      Where.new("x=1").or("x=2").to_sql.should == "(x=1) OR (x=2)"
    end
    
    it "can receive another Where object" do
      where = Where.new
      where.or Where.new("x=1")
      where.to_s.should == "((x=1))"
    end
  end
  
  describe "#and" do
    it "appends and conditions, parenthetically grouped by statements inside of blocks" do
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
    
    it "returns the where object so that it can be daisy chained" do
      Where.new("x=1").and("x=2").to_sql.should == "(x=1) AND (x=2)"
    end

    it "receives a hash and converts each key/value pair as a AND criteria" do
      Where.new("boogy").and({:field1 => "value1", :field2 => "value2"}).to_sql.should == "(boogy) AND (field1 = 'value1' AND field2 = 'value2')"
    end
    
    it "can receive another Where object" do
      where = Where.new
      where.and Where.new("x=1")
      where.to_s.should == "((x=1))"
    end
  end

  describe "#and_not" do
    it "prepends NOT before the condition, even if only one condition exists" do
      w = Where.new

      w.and_not { w.or("x = ?", 1).or("x = ?", 2) }

      w.to_s.should == "NOT ((x = 1) OR (x = 2))"
    end
  end
  
  describe "#or_not" do
    it "prepends NOT before the condition, even if only one condition exists" do
      w = Where.new

      w.and_not "x = ?", 1
      w.and_not "y = ?", 1

      w.to_s.should == "NOT (x = 1) AND NOT (y = 1)"
    end
    
    it "receives a block and parenthetically groups all statements within" do
      w = Where.new

      w.or_not { w.or("x = ?", 1).or("x = ?", 2) }

      w.to_s.should == "NOT ((x = 1) OR (x = 2))"
    end
    
    it "appends the 2nd condition with an or NOT" do
      w = Where.new

      w.or_not "x = ?", 1
      w.or_not "y = ?", 1

      w.to_s.should == "NOT (x = 1) OR NOT (y = 1)"
    end
  end
  
  describe "Kernel#Where" do
    it "Behaves like a shortcut for Where.new" do
      Where { |w| w & ["x=?", 1] }.to_s.should == "(x=1)"
    end
  end
  
  it "should nest mixed AND / OR clauses properly" do
    w = Where.new
    w.and { 
      w.or "x = 1"
      w.or "x = 2"
    }
    w.and "y = 1"
    w.to_sql.should == "((x = 1) OR (x = 2)) AND (y = 1)"
  end

  describe "#to_s{ql}" do
    it "returns a valid clause when the where clause is empty" do
      Where.new.to_s.should == "(true)"
    end
  end
end
