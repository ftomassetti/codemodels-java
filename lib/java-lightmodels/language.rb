require 'lightmodels'

module LightModels
module Java

class JavaLanguage < Language
	def initialize
		super('Java')
		@extensions << 'java'
		@parser = LightModels::Java::Parser.new
	end
end

LightModels.register_language JavaLanguage.new

end
end