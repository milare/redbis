require 'rubygems'
require 'ruby-debug'
require 'active_support'
require 'active_support/all'
require 'redbis/attributes'
require 'redbis/callbacks'
require 'redbis/base'

class User < Redbis::Base

  field :foo, :default => 1
  field :bar, :default => 'foobar'
  
  use_key :people
  
end

class Post < Redbis::Base

  field :title, :default => 'post title'
  field :body

  before_create :test_before_callback
  after_create :test_after_callback

  def test_before_callback
    puts "before"
  end

  def test_after_callback
    puts "after"
  end

end

