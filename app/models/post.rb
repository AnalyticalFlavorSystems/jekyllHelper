class Post < ActiveRecord::Base
  attr_accessible :content, :markdown, :title, :post_date, :tags, :description, :author, :subtitle
  validates :title, :author, :content, :description, :tags, :post_date, presence: true
  before_save do |post|
      DateTime.strptime(post.post_date, "%F %T")
  end
end
