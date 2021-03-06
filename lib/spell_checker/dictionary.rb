
class Dictionary
  # Parent dictionary class to be extended by specific dictionaries
  def initialize
  end
  def word_exists?
    raise RuntimeException "Not Implemented Yet"
  end
  
end

class TextDictionary < Dictionary
  require 'ftools'
  
  # CURRENTLY USES AN ARRAY TO STORE DICTIONARY, SO DON'T USE TOO BIG A SOURCE
  # WILL MOVE TO A BLOOM FILTER ONCE I PROPERLY UNDERSTAND HOW TO USE IT
  
  def initialize(params={})
    @params = params
    if @params[:base_dictionary].nil?
      @base_file = File.expand_path(File.dirname(__FILE__) + "/dictionary.txt")
    else
      @base_file = @params[:base_dictionary]
      raise "Unable to find base dictionary '#{@params[:base_dictionary]}'" unless File.exist?(@params[:base_dictionary])
    end
    if @params[:custom_dictionary].nil?
      @custom_file = File.expand_path(File.dirname(__FILE__) + "/custom.txt")
    else
      @custom_file = @params[:custom_dictionary]
      raise "Unable to find base dictionary '#{@params[:custom_dictionary]}'" unless File.exist?(@params[:custom_dictionary])
    end

    @word_list = []    
    File.open( @custom_file ) do |io|
      io.each {|line| line.chomp! ; @word_list << line}
    end
    File.open( @base_file ) do |io|
      io.each {|line| line.chomp! ; @word_list << line}
    end
  end
  
  def word_exists?(word)
    @word_list.include?(word.downcase) or @word_list.include?(word)
    #File.open(@custom_file, "w") unless File.exists?(@custom_file)
    #File.open(@base_file, "w") unless File.exists?(@base_file)
    
    #File.open( @custom_file ) do |io|
    #  io.each {|line| line.chomp! ; return true if line == word}
    #end
    #File.open( @base_file ) do |io|
    #  io.each {|line| line.chomp! ; return true if line == word}
    #end
    #false
  end
  def suggested_words(word)
    words = []
    (0..word.length).to_a.each do |i|
      regex = "^"
      regex += word[0..i-1] unless i==0
      regex += "."
      regex += word[i+1..-1] unless i==word.length
      regex += "$"
      words << @word_list.reject{|item| !Regexp.new(regex).match(item)}
    end
    words.flatten.uniq.sort
  end

  def filter_stemmed_words
    dictionary = []
    puts "loading stemmed list"
    File.move (@base_file, File.expand_path(File.dirname(@base_file) + "/original_dictionary.txt"))
    File.open( File.expand_path(File.dirname(__FILE__) + "/original_dictionary.txt") ) do |io|
      io.each {|line| puts "loading #{line}"; line.chomp! ; dictionary << line.stem}
    end

    dictionary.uniq!
    puts "#{dictionary.length} stemmed words found"
    
    puts "writing to #{@base_file}"
    File.open(@base_file, "w") do |io|
      dictionary.each do |word|
        io.write(word + "\n")
      end
    end
    
  end

end
