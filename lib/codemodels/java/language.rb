require 'codemodels'

module CodeModels
module Java

class JavaLanguage < Language
	def initialize
		super('Java')
		@extensions << 'java'
		@parser = CodeModels::Java::Parser.new
	end
end

CodeModels.register_language JavaLanguage.new

end
end