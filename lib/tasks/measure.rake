namespace :measure do
  require 'benchmark'
  ####################################################################################################
  # Create File
  #
  # Script Description
  ### Used for the creation of a 1 GB file text file
  ####################################################################################################

  one_megabyte = 1024 * 1024
  chunk_size = 4096
  buf = ''

  task all: :environment do
    all_sizes = [0.1, 0.5, 1, 5, 10, 50, 100, 500] # , 10, 50, 100, 500, 1000]
    all_file_types = ['long_line', 'medium_line', 'short_line', 'only_paragraphs']
    all_script_types = ['read_file', 'enum', 'final']
    puts 'Pre Processing all files...'
    system('rails pre_processing:all')
    puts 'Star getting the metric values...'
    print "script;file_name;file_size;index;max;freed_objs;time;used_memory\n"
    1.times do
      all_script_types.each do |script_type|
        all_sizes.each do |size|
          all_file_types.each do |file_type|
            next if size > 100 && file_type == 'only_paragraphs'

            fd = FileDetail.find_by(name: "#{size}mb_#{file_type}.txt")
            n_lines = fd.lines_number

            system("rails measure:#{script_type}[#{size},#{file_type},1,#{n_lines}]")
            system("rails measure:#{script_type}[#{size},#{file_type},#{n_lines / 2},#{n_lines}]")
            system("rails measure:#{script_type}[#{size},#{file_type},#{n_lines},#{n_lines}]")
          end
        end
      end
    end
  end

  task :enum, %i[size type index max] => [:environment] do |_task, args|
    file_name = "#{args[:size]}mb_#{args[:type]}.txt"
    print "enum;#{file_name};#{args[:size]};#{args[:index]};#{args[:max]}"
    print file_name
    index = args[:index].to_i
    counter = 0
    profile do
      file = File.new(file_name)
      file.each do |line|
        if counter == index - 1
          print " - #{line} "
          break
        end

        counter += 1
      end
    end
  end

  task :read_file, %i[size type index max] => [:environment] do |_task, args|
    file_name = "#{args[:size]}mb_#{args[:type]}.txt"
    print "read_file;#{file_name};#{args[:size]};#{args[:index]};#{args[:max]}"
    index = args[:index].to_i
    final_line = ''
    profile do
      # file = File.read("#{args[:size]}mb_#{args[:type]}.txt")
      # line_count = 0

      # file.each_char do |c|
      #   line_count += 1 if c == "\n"
      #   if line_count == index
      #     # puts final_line
      #     break
      #   end

      #   final_line.insert(-1, c) if line_count == index - 1
      # end
      # # puts final_line
      file = File.new(file_name).readlines
      print " - #{file[index - 1]} "
    end
  end

  task :final, %i[size type index max] => [:environment] do |_task, args|
    file_name = "#{args[:size]}mb_#{args[:type]}.txt"
    print "final;#{file_name};#{args[:size]};#{args[:index]};#{args[:max]}"

    fd = FileDetail.find_by(name: file_name)
    profile do
      file = File.new(file_name)
      index = args[:index].to_i
      ci = ChunkInfo.where(file_detail_id: fd.id).where('last_line_number < ?', index).last

      chunk_steps = ci.present? ? ci.chunk_number : 0
      counter = ci.present? ? ci.last_line_number : 1
      file.seek(chunk_steps * chunk_size)

      file.each do |line|
        if counter == index
          print line
          break
        end

        counter += 1
      end
    end
  end

  private

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
