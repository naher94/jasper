class Swatch < ActiveRecord::Base
	
	has_many :images
	#validates_presence_of :url

end