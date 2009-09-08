require File.dirname(__FILE__) + '/../spec_helper'

describe "SearchBuilder" do
  before(:each) do
    @object = OpenStruct.new
    @sb = SearchBuilder.new(@object)
  end
    
  it "search_builder_date_range" do
    @object.created_at_min = "Jan 2 2007 5:30"
    @object.created_at_max = "Jan 5 2007 5:30"
    @sb.range_on("proposals.created_at", :cast => :date)
    
    @sb.to_sql.should == "(proposals.created_at >= '2007-01-02') AND (proposals.created_at <= '2007-01-05')"
  end
  
  it "search_builder_date_range__nil_values__shouldnt_append_anything" do
    @sb.range_on("users.created_at", :cast => :date)
    
    @sb.to_sql.should == "(true)"
  end
  
  it "like_search" do
    @object.first_name = "Tim"
    @sb.like_on("users.first_name")
    
    @sb.to_sql.should == "(users.first_name like 'Tim%')"
  end
  
  it "equal_search" do
    @object.first_name = "Tim"
    @sb.equal_on("users.first_name")
    
    @sb.to_sql.should == "(users.first_name = 'Tim')"
  end
  
  it "in_search" do
    @object.value = [1,2,3,4]
    @sb.in_on "attributes.value"
    @sb.to_sql.should == "(attributes.value in (1,2,3,4))"
  end
  
  it "dot_in_field__should_be_smart_and_figure_it_out" do
    @object.first_name = "Tim"
    @sb.equal_on("users.first_name")
    @sb.to_sql.should == "(users.first_name = 'Tim')"
  end
  
  it "for_table__should_prepend" do
    @object.first_name = "Tim"
    @sb.for_table "users" do
      @sb.equal_on("first_name")
    end
    
    @sb.to_sql.should == "(users.first_name = 'Tim')"
  end
  
  it "for_table_no_block__should_prepend" do
    @object.first_name = "Tim"
    @sb.for_table "users"
    @sb.equal_on("first_name")
    
    @sb.to_sql.should == "(users.first_name = 'Tim')"
  end
  
  it "use_symbol__should_process_ok__should_append" do
    @object.first_name = "Tim"
    @sb.equal_on(:first_name)
    
    @sb.to_sql.should == "(first_name = 'Tim')"
    
  end
  
  
end
