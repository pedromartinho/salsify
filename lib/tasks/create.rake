namespace :create do
  require 'benchmark'
  one_megabyte = 1024 * 1024
  file_sizes = [0.1, 0.5, 1, 5, 10, 50, 100, 500]

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
    file_sizes.each do |file_s|
      system("rails create:create_long_line_file[#{file_s}]")
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
    file_sizes.each do |file_s|
      system("rails create:medium_line_file[#{file_s}]")
    end
  end

  #################################################################################################
  # Script - Create Short Line Files Script
  #
  # Description
  ### Used for the creation of 0.1, 0.5, 1, 5, 10, 50, 100 and 500 MB text files with a low number
  ### of characters per line
  #################################################################################################
  task short_line_files: :environment do
    file_sizes.each do |file_s|
      system("rails create:short_line_file[#{file_s}]")
    end
  end

  #################################################################################################
  # Script - Create Only Paragraphs Files Script
  #
  # Description
  ### Used for the creation of 0.1, 0.5, 1, 5, 10, 50, 100 and 500 MB text files with only empty
  ### lines
  #################################################################################################
  task only_paragraphs_files: :environment do
    file_sizes.each do |file_s|
      system("rails create:only_paragraphs_file[#{file_s}]")
    end
  end

  #################################################################################################
  # Script - Create Long Line File Script
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
  # Function - create a long line.
  ### INPUT: max number of
  ### Creates a line with 0 to 2000 words, each word with 0 to 25 characters, meaning each line can
  ### have a total of 52000 characters although it is nearly impossible
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

  def profile_memory
    memory_usage_before = `ps -o rss= -p #{Process.pid}`.to_i
    yield
    memory_usage_after = `ps -o rss= -p #{Process.pid}`.to_i

    used_memory = ((memory_usage_after - memory_usage_before) / 1024.0).round(2)
    # puts "Memory usage: #{used_memory} MB"
    print ";#{used_memory}\n"
  end

  def profile_time
    time_elapsed = Benchmark.realtime do
      yield
    end

    # puts "Time: #{time_elapsed.round(3)} seconds"
    print ";#{time_elapsed.round(3)}"
  end

  def profile_gc
    GC.start
    before = GC.stat(:total_freed_objects)
    yield
    GC.start
    after = GC.stat(:total_freed_objects)

    # puts "Objects Freed: #{after - before}"
    print ";#{after - before}"
  end

  def profile
    profile_memory do
      profile_time do
        profile_gc do
          yield
        end
      end
    end
  end
end
