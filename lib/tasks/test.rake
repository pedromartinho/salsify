namespace :test do
  require 'benchmark'
  ####################################################################################################
  # Create File
  #
  # Script Description
  ### Used for the creation of a 1 GB file text file
  ####################################################################################################

  one_megabyte = 1024 * 1024

  task create_all_files: :environment do
    system('rails test:create_long_line_files')
    system('rails test:create_medium_line_files')
    system('rails test:create_short_line_files')
    system('rails test:create_only_paragraphs_files')
  end

  task create_long_line_files: :environment do
    system('rails test:create_long_line_file[0.1]')
    system('rails test:create_long_line_file[0.5]')
    system('rails test:create_long_line_file[1]')
    system('rails test:create_long_line_file[5]')
    system('rails test:create_long_line_file[10]')
    system('rails test:create_long_line_file[50]')
    system('rails test:create_long_line_file[100]')
    system('rails test:create_long_line_file[500]')
    # system('rails test:create_long_line_file[1000]')
  end

  task create_medium_line_files: :environment do
    system('rails test:create_medium_line_file[0.1]')
    system('rails test:create_medium_line_file[0.5]')
    system('rails test:create_medium_line_file[1]')
    system('rails test:create_medium_line_file[5]')
    system('rails test:create_medium_line_file[10]')
    system('rails test:create_medium_line_file[50]')
    system('rails test:create_medium_line_file[100]')
    system('rails test:create_medium_line_file[500]')
    # system('rails test:create_medium_line_file[1000]')
  end

  task create_short_line_files: :environment do
    system('rails test:create_short_line_file[0.1]')
    system('rails test:create_short_line_file[0.5]')
    system('rails test:create_short_line_file[1]')
    system('rails test:create_short_line_file[5]')
    system('rails test:create_short_line_file[10]')
    system('rails test:create_short_line_file[50]')
    system('rails test:create_short_line_file[100]')
    system('rails test:create_short_line_file[500]')
    # system('rails test:create_short_line_file[1000]')
  end

  task create_only_paragraphs_files: :environment do
    system('rails test:create_only_paragraphs_file[0.1]')
    system('rails test:create_only_paragraphs_file[0.5]')
    system('rails test:create_only_paragraphs_file[1]')
    system('rails test:create_only_paragraphs_file[5]')
    system('rails test:create_only_paragraphs_file[10]')
    system('rails test:create_only_paragraphs_file[50]')
    system('rails test:create_only_paragraphs_file[100]')
    system('rails test:create_only_paragraphs_file[500]')
    # system('rails test:create_only_paragraphs_file[1000]')
  end

  task :create_long_line_file, [:size] => [:environment] do |_task, args|
    File.open("./#{args[:size]}mb_long_line.txt", 'wb') do |file|
      file.write("#{create_long_line}\n") while File.size(file).to_f / one_megabyte < args[:size].to_f
    end
  end

  task :create_medium_line_file, [:size] => [:environment] do |_task, args|
    File.open("./#{args[:size]}mb_medium_line.txt", 'wb') do |file|
      file.write("#{create_medium_line}\n") while File.size(file).to_f / one_megabyte < args[:size].to_f
    end
  end

  task :create_short_line_file, [:size] => [:environment] do |_task, args|
    File.open("./#{args[:size]}mb_short_line.txt", 'wb') do |file|
      file.write("#{create_short_line}\n") while File.size(file).to_f / one_megabyte < args[:size].to_f
    end
  end

  task :create_only_paragraphs_file, [:size] => [:environment] do |_task, args|
    File.open("./#{args[:size]}mb_only_paragraphs.txt", 'wb') do |file|
      file.write("\n") while File.size(file).to_f / one_megabyte < args[:size].to_f
    end
  end

  ####################################################################################################
  # Read simple file
  #
  # Script Description
  ### First script for testing the initial metrics
  ####################################################################################################

  task simple_file: :environment do
    file = nil
    chunk_size = 4096
    buf = ''
    profile do
      file = File.new(ENV['FILE_NAME'])
      while buf = file.read(chunk_size)
        # puts buf
        buf.tap { |buf| buf }
      end
    end
  end

  task each_entry: :environment do
    # require 'base64'
    # require 'zlib'
    # require 'stringio'

    # profile do
    #   file = File.foreach('0.1mb_long_line.txt.gz')
    #   file.each_with_index do |line, idx|
    #     if idx == 1
    #       puts line
    #       raw = Base64.decode64(line)
    #       line_io = StringIO.new(raw)
    #       gz = Zlib::GzipReader.new(line_io)
    #       break
    #     end
    #     line
    #   end
    # end
    profile do
      file = File.foreach('100mb_long_line.txt')
      file.each_with_index do |line, idx|
        if idx == 100_000
          puts line
          break
        end
        line
      end
    end
    file = nil
    profile do
      file = File.new('100mb_long_line.txt').readlines
      puts file[100_000]
    end
  end

  private

  def create_long_line
    letters = [('a'..'z'), ('A'..'Z')].map(&:to_a).flatten # From a to z and from A to Z - All characters considered in ASCII
    words = []
    (0..rand(2000)).each do
      word = (0..rand(25)).map { letters[rand(letters.length)] }.join # Gererate random strings with lenth between 1 and 26
      words.push(word)
    end
    words.join(' ')
  end

  def create_medium_line
    letters = [('a'..'z'), ('A'..'Z')].map(&:to_a).flatten # From a to z and from A to Z - All characters considered in ASCII
    words = []
    (0..rand(250)).each do
      word = (0..rand(25)).map { letters[rand(letters.length)] }.join # Gererate random strings with lenth between 1 and 26
      words.push(word)
    end
    words.join(' ')
  end

  def create_short_line
    letters = [('a'..'z'), ('A'..'Z')].map(&:to_a).flatten # From a to z and from A to Z - All characters considered in ASCII
    words = []
    (0..rand(5)).each do
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
    puts "Memory usage: #{used_memory} MB"
  end

  def profile_time
    time_elapsed = Benchmark.realtime do
      yield
    end

    puts "Time: #{time_elapsed.round(2)} seconds"
  end

  def profile_gc
    GC.start
    before = GC.stat(:total_freed_objects)
    yield
    GC.start
    after = GC.stat(:total_freed_objects)

    puts "Objects Freed: #{after - before}"
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
