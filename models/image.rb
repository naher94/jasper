class Image < ActiveRecord::Base

	belongs_to :swatch 
	#has_many :images  
	#validates_presence_of :url

end