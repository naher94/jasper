class Image < ActiveRecord::Base

	belongs_to :swatch 
	#has_many :images  
	#validates_presence_of :url
	def self.save_image_data(data)
	  
		data.each do |url|
			image = Image.new
			#poulate
			image.date = Time.now
			image.image = url
			#save
			image.save!
		end
	end

	def self.get_dribbble_photos(hex)
	  url = "https://dribbble.com/colors/#{ hex.gsub('#', '') }"
	  document = Nokogiri::HTML(open(url))

	  images = document.css(".dribbble-link noscript img")

	  #what is images? not an array??	  
	  image_hrefs = []


	  images.each do | image |
	   	
	    img = image.attr('src').gsub('_teaser.','.')

	    image_hrefs << "#{img.to_s}"
	  end

	  return image_hrefs.sample(4)
	end

	def self.load_image(hex) #data is a swatch point
		#get hex from the lastest entry in the db
		#pass it in as a n argument

		images = self.get_dribbble_photos(hex)

		unless images.empty?
			self.save_image_data( images )
		end
	end
end