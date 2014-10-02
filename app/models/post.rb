class Post < ActiveRecord::Base
  attr_accessible :content, :markdown, :title, :post_date, :tags, :description, :author
  validates :title, :author, :content, presence: true
end
