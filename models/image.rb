class Image < ActiveRecord::Base

	belongs_to :swatch 
	#has_many :images  
	#validates_presence_of :url
	def self.save_image_data(data, swatch)
	  
		for i in data.length
			image = Image.new
			image.swatch = swatch
			#poulate
			image.date = Time.now
			image.image = data[i]
			#save
			image.save!
		end
	end

	def self.get_dribbble_photos(hex)
	  url = "https://dribbble.com/colors/#{ hex.gsub('#', '') }"
	  document = Nokogiri::HTML(open(url))

	  images = document.css(".dribbble-link noscript img")
	  image_hrefs = Array.new

	  images.each do | image |
	    image_hrefs.push(image.attr('src').gsub('_teaser.','.'))
	  end

	  return image_hrefs.sample(4)
	end

	def self.load_image(data, swatch) #data is a swatch point
		#get hex from the lastest entry in the db
		#pass it in as a n argument
		hex = data.hex
		self.save_image_data(self.get_dribbble_photos(hex), swatch)
	end
end