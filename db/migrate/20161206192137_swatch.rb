class Swatch < ActiveRecord::Migration[5.0]
  def change
  	create_table :swatch do |t|

	  	t.datetime :date
	  	t.string :name
	  	t.string :hex
	  	t.string :pantone
	  	t.string :themetic_words
	  	#add the images table & link it
	end
  end
end
