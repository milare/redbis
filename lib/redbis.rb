require 'rubygems'
require 'ruby-debug'
require 'active_support'
require 'active_support/all'
require 'redbis/attributes'
require 'redbis/connection'
require 'redbis/callbacks'
require 'redbis/validations'
require 'redbis/base'
require 'redis'

class User < Redbis::Base

  field :foo, :default => 1
  field :bar, :default => 'foobar'
  
  use_key :people
  
end

class Post < Redbis::Base

  field :title, :default => 'post title'
  field :body

  before_initialize :test_before_callback
  after_initialize :test_after_callback
  before_validation :define_body_field

  validates :presence, :body, :title

  def test_before_callback
    puts "before"
  end

  def test_after_callback
    puts "after"
  end

  def define_body_field
    self.body ||= "callback for body"
  end

end

