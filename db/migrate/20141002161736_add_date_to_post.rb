class AddDateToPost < ActiveRecord::Migration
  def change
    add_column :posts, :post_date, :string
  end
end
