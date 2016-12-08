class CreateSwatches < ActiveRecord::Migration[5.0]
  def change
  	create_table :swatches do |t|

	  	t.datetime :date
	  	t.string :name
	  	t.string :hex
	  	t.string :pantone
	  	t.string :themetic_words
	end
  end
end
