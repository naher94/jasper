class Swatch < ActiveRecord::Base
	
	has_many :images
	#validates_presence_of :url
	def self.get_pantone_data
	  url = "https://www.pantone.com/colorstrology"
	  document = Nokogiri::HTML(open(url))

	  color = self.parse_pantone_color(document)
	  info = self.parse_pantone_info(document)
	  words = self.parse_pantone_words(document)

	  #{:pantone_words=>["UNUSUAL", "LEADER", "CREATIVE"], :pantone_color=>"#3D81AC", :pantone_name=>"Cendre Blue", :pantone_number=>"17-4131"}
	  return { pantone_words: words, pantone_color: color, pantone_name: info[:name], pantone_number: info[:number] }
	end

	def self.parse_pantone_color(document)
	  node = document.css('#ctl00_ctlDynamicControl1_plColorstrologyBackgroundPanel').first
	  color_style = node["style"].to_s
	  return color_style.gsub( "background-color:", "").gsub(";height:190px;width:190px;", "")
	end

	def self.parse_pantone_info(document)
	  node = document.css('.numLogon')
	  info_array = node.text.gsub(/\s/,',').split(",") - [""]
	  return { number: info_array[0], name: "#{ info_array[1] } #{ info_array[2] } #{ info_array[3] } #{ info_array[4] } #{ info_array[5] }".strip  }
	end

	def self.parse_pantone_words(document)
	  node = document.css('.keyLogon')
	  return node.first.text.gsub(/\s/,',').split(",") - [""]
	end

	def self.save_pantone_data(data)
	  swatch = Swatch.new
	  
	  #poulate
	  swatch.date = Time.now
	  swatch.name = data[:pantone_name]
	  swatch.hex = data[:pantone_color]
	  swatch.pantone = data[:pantone_number]
	  swatch.themetic_words = data[:pantone_words].to_json
	  #save
	  swatch.save!
	end

	def self.load_pantone
		self.save_pantone_data(self.get_pantone_data)
	end
end