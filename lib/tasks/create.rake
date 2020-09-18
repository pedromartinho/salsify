require "#{Rails.root}/app/helpers/profile_helper"
include ProfileHelper

namespace :create do
  #################################################################################################
  # Script - Create All Files Script
  #
  # Description
  ### Used for the creation of 0.1, 0.5, 1, 5, 10, 50, 100 and 500 MB text files with diferent
  ### number of characters quantity per line
  #################################################################################################
  task all_files: :environment do
    system('rails create:long_line_files')
    system('rails create:medium_line_files')
    system('rails create:short_line_files')
    system('rails create:only_paragraphs_files')
  end

  #################################################################################################
  # Script - Create Long Line Files Script
  #
  # Description
  ### Used for the creation of 0.1, 0.5, 1, 5, 10, 50, 100 and 500 MB text files with a high number
  ### of characters per line
  #################################################################################################
  task long_line_files: :environment do
    all_sizes.each do |file_s|
      system("rails create:long_line_file[#{file_s}]")
    end
  end

  #################################################################################################
  # Script - Create Medium Line Files Script
  #
  # Description
  ### Used for the creation of 0.1, 0.5, 1, 5, 10, 50, 100 and 500 MB text files with a medium
  ### number of characters per line
  #################################################################################################
  task medium_line_files: :environment do
    all_sizes.each do |file_s|
      system("rails create:medium_line_file[#{file_s}]")
    end
  end

  #################################################################################################
  # Script - Create Short Line Files
  #
  # Description
  ### Used for the creation of 0.1, 0.5, 1, 5, 10, 50, 100 and 500 MB text files with a low number
  ### of characters per line
  #################################################################################################
  task short_line_files: :environment do
    all_sizes.each do |file_s|
      system("rails create:short_line_file[#{file_s}]")
    end
  end

  #################################################################################################
  # Script - Create Only Paragraphs Files
  #
  # Description
  ### Used for the creation of 0.1, 0.5, 1, 5, 10, 50, 100 and 500 MB text files with only empty
  ### lines
  #################################################################################################
  task only_paragraphs_files: :environment do
    all_sizes.each do |file_s|
      system("rails create:only_paragraphs_file[#{file_s}]")
    end
  end

  #################################################################################################
  # Script - Create Long Line File
  #
  # Description
  ### INPUT: size in MB
  ### Accepts a size argument and will create a file with high number of character per line with
  ### approximatly the given size
  #################################################################################################
  task :long_line_file, [:size] => [:environment] do |_task, args|
    File.open("./#{args[:size]}mb_long_line.txt", 'wb') do |file|
      file.write("#{create_line(2000)}\n") while File.size(file).to_f / one_megabyte < args[:size].to_f
    end
    puts "Done #{args[:size]}mb_long_line.txt"
  end

  #################################################################################################
  # Script - Create Medium Line File
  #
  # Description
  ### INPUT: size in MB
  ### Accepts a size argument and will create a file with medium number of character per line with
  ### approximatly the given size
  #################################################################################################
  task :medium_line_file, [:size] => [:environment] do |_task, args|
    File.open("./#{args[:size]}mb_medium_line.txt", 'wb') do |file|
      file.write("#{create_line(250)}\n") while File.size(file).to_f / one_megabyte < args[:size].to_f
    end
    puts "Done #{args[:size]}mb_medium_line.txt"
  end

  #################################################################################################
  # Script - Create Short Line File
  #
  # Description
  ### INPUT: size in MB
  ### Accepts a size argument and will create a file with low number of character per line with
  ### approximatly the given size
  #################################################################################################
  task :short_line_file, [:size] => [:environment] do |_task, args|
    File.open("./#{args[:size]}mb_short_line.txt", 'wb') do |file|
      file.write("#{create_line(5)}\n") while File.size(file).to_f / one_megabyte < args[:size].to_f
    end
    puts "Done #{args[:size]}mb_short_line.txt"
  end

  #################################################################################################
  # Script - Create Only Paragraph File
  #
  # Description
  ### INPUT: size in MB
  ### Accepts a size argument and will create a file with with only empty lines with approximatly
  ### the given size
  #################################################################################################
  task :only_paragraphs_file, [:size] => [:environment] do |_task, args|
    File.open("./#{args[:size]}mb_only_paragraphs.txt", 'wb') do |file|
      file.write("\n") while File.size(file).to_f / one_megabyte < args[:size].to_f
    end
    puts "Done #{args[:size]}mb_only_paragraphs.txt"
  end

  private

  #################################################################################################
  # Function - Create Line
  #
  # Description
  ### INPUT: max number of words
  ### Requires a max number of words argument and creates a line with 0 to max number of words,
  ### each word with 0 to 25 characters
  #################################################################################################
  def create_line(max_words)
    letters = [('a'..'z'), ('A'..'Z')].map(&:to_a).flatten # From a to z and from A to Z - All characters considered in ASCII
    words = []
    (0..rand(max_words)).each do
      word = (0..rand(25)).map { letters[rand(letters.length)] }.join # Gererate random strings with lenth between 1 and 26
      words.push(word)
    end
    words.join(' ')
  end
end
