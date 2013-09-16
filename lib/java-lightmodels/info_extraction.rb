module LightModels

module Java

module InfoExtraction

def self.is_camel_case_str(s)
	not s.index /[^A-Za-z0-9]/
end

def self.camel_to_words(camel)
	return [''] if camel==''

	# if camel contains an upcase word and it is followed by something then
	# extract it and process the camel before and after
	# to understand where the upcase word ends we have to look if there is
	# a downcase char after
	upcaseword_index = camel.index /[A-Z]{2}/
	number_index = camel.index /[0-9]/
	if upcaseword_index
		if upcaseword_index==0
			words_before = []
		else
			camel_before = camel[0..upcaseword_index-1]
			words_before = camel_to_words(camel_before)
		end

		camel_from = camel[upcaseword_index..-1]
		has_other_after = camel_from.index /[^A-Z]/		
		if has_other_after
			is_lower_case_after = camel_from[has_other_after].index /[a-z]/
			if is_lower_case_after
				mod = 1
			else
				mod = 0
			end
			upcase_word = camel_from[0..has_other_after-1-mod]
			camel_after = camel_from[has_other_after-mod..-1]
			words_after = camel_to_words(camel_after)
		else
			upcase_word = camel_from
			words_after = []
		end
		words = words_before
		words << upcase_word
		words = words + words_after
		words
	elsif number_index
		if number_index==0
			words_before = []
		else
			camel_before = camel[0..number_index-1]
			words_before = camel_to_words(camel_before)
		end

		camel_from = camel[number_index..-1]
		has_other_after = camel_from.index /[^0-9]/
		if has_other_after
			number_word = camel_from[0..has_other_after-1]
			camel_after = camel_from[has_other_after..-1]
			words_after = camel_to_words(camel_after)
		else
			number_word = camel_from
			words_after = []
		end
		words = words_before
		words << number_word
		words = words + words_after
		words		
	else
		camel.split /(?=[A-Z])/
	end    
end

class JavaSpecificInfoExtractionLogic
	
	def terms_containing_value?(value)
		LightModels::Java::InfoExtraction.is_camel_case_str(value)
	end

	def to_words(value)
		LightModels::Java::InfoExtraction.camel_to_words(value)
	end

	def concat(a,b)
		a+b
	end

end

def self.terms_map(model_node,context=nil)
	LightModels::InfoExtraction.terms_map(JavaSpecificInfoExtractionLogic.new,model_node,context)
end

end

end

end
