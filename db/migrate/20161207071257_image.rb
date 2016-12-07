class Image < ActiveRecord::Migration[5.0]
  def change
  	create_table :image do |t|

	  	t.datetime :date
	  	t.url :image
	end
  end
end
