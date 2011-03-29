require 'lib/redbis'

class User < Redbis::Base

  field :foo, :default => 1
  field :bar, :default => 'foobar'
  
  use_key :people

  has_many :posts
  
end

class Post < Redbis::Base

  field :title, :default => 'post title'
  field :body

  before_initialize :test_before_callback
  after_initialize :test_after_callback
  before_validation :define_body_field

  validates :presence, :body, :title

  belongs_to :user

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


u = User.new
u.save

p = Post.new(:user_id => u.id)
p.save


p2 = Post.new(:title => 'new one', :user_id => u.id)
p2.save

posts = Post.all
p3 = Post.find_by_title p2.title

p2 == p3


