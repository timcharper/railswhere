require File.dirname(__FILE__) + '/../test_helper'
class SearchBuilderTest < Test::Unit::TestCase
  def setup
    @object = OpenStruct.new
    @sb = SearchBuilder.new(@object)
  end
    
  def test__search_builder_date_range
    @object.created_at_min = "Jan 2 2007 5:30"
    @object.created_at_max = "Jan 5 2007 5:30"
    @sb.range_on("proposals.created_at", :cast => :date)
    
    assert_equal("(proposals.created_at >= '2007-01-02') AND (proposals.created_at <= '2007-01-05')", @sb.to_sql)
  end
  
  def test__search_builder_date_range__nil_values__shouldnt_append_anything
    @sb.range_on("users.created_at", :cast => :date)
    
    assert_nil(@sb.to_sql)
  end
  
  def test__like_search
    @object.first_name = "Tim"
    @sb.like_on("users.first_name")
    
    assert_equal("(users.first_name like 'Tim%')", @sb.to_sql)
  end
  
  def test__equal_search
    @object.first_name = "Tim"
    @sb.equal_on("users.first_name")
    
    assert_equal("(users.first_name = 'Tim')", @sb.to_sql)
  end
  
  def test__in_search
    @object.value = [1,2,3,4]
    @sb.in_on "attributes.value"
    assert_equal("(attributes.value in (1,2,3,4))", @sb.to_sql)
  end
  
  def test__dot_in_field__should_be_smart_and_figure_it_out
    @object.first_name = "Tim"
    @sb.equal_on("users.first_name")
    assert_equal("(users.first_name = 'Tim')", @sb.to_sql)
  end
  
  def test__for_table__should_prepend
    @object.first_name = "Tim"
    @sb.for_table "users" do
      @sb.equal_on("first_name")
    end
    
    assert_equal("(users.first_name = 'Tim')", @sb.to_sql)
  end
  
  def test__for_table_no_block__should_prepend
    @object.first_name = "Tim"
    @sb.for_table "users"
    @sb.equal_on("first_name")
    
    assert_equal("(users.first_name = 'Tim')", @sb.to_sql)
  end
  
  def test__use_symbol__should_process_ok__should_append
    @object.first_name = "Tim"
    @sb.equal_on(:first_name)
    
    assert_equal("(first_name = 'Tim')", @sb.to_sql)
    
  end
  
  
end
