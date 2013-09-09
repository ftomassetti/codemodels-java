require 'test/unit'
require 'java-lightmodels'

include JavaModel

class TestInfoExtraction < Test::Unit::TestCase

	def test_camel_to_words_single_word_upcase
		assert_equal ['CIAO'],InfoExtraction.camel_to_words('CIAO')
	end

	def test_camel_to_words_single_word_downcase
		assert_equal ['ciao'],InfoExtraction.camel_to_words('ciao')
	end

	def test_camel_to_words_proper_starting_down
		assert_equal ['ciao','Bello'],InfoExtraction.camel_to_words('ciaoBello')
	end

	def test_camel_to_words_proper_starting_up
		assert_equal ['Ciao','Bello'],InfoExtraction.camel_to_words('CiaoBello')
	end

	def test_camel_to_words_with_numbers
		assert_equal ['test','1'],InfoExtraction.camel_to_words('test1')
	end

	def test_camel_to_words_upcase_numbers
		assert_equal ['TEST','1'],InfoExtraction.camel_to_words('TEST1')
	end

	def test_camel_to_words_with_uppercase_word
		assert_equal ['Ciao','BELLO','Come','Va'],InfoExtraction.camel_to_words('CiaoBELLOComeVa')
	end

	def test_camel_to_words_empty
		assert_equal [''],InfoExtraction.camel_to_words('')
	end

end
