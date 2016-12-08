class CreateImages < ActiveRecord::Migration[5.0]
  def change
  	create_table :images do |t|

	  	t.datetime :date
	  	t.string :image
	end
  end
end
