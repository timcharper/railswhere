require "rubygems"

require 'test/unit'
require 'active_record'


ActiveRecord::Base.establish_connection(
  :adapter => "sqlite3", 
  :database => File.join(File.dirname(__FILE__), "db/test.db")
)

for file in ["../lib/where.rb", "../lib/search_builder.rb"]
  require File.expand_path(File.join(File.dirname(__FILE__), file))
end

def dbg; require 'ruby-debug'; debugger; end

class Object
  def to_regexp
    is_a?(Regexp) ? self : Regexp.new(Regexp.escape(self.to_s))
  end
end