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
    all_script_types = ['read_file', 'enum', 'read_chunk']
    print "script;file_size;index;max;freed_objs;time;used_memory\n"
    3.times do
      all_script_types.each do |script_type|
        all_sizes.each do |size|
          all_file_types.each do |file_type|
            next if size > 100 && file_type == 'only_paragraphs'

            lines = File.new("#{size}mb_#{file_type}.txt").readlines
            n_lines = 0
            file = File.new("#{args[:size]}mb_#{args[:type]}.txt")
            file.each do |_line|
              break if counter == index - 1

              counter += 1
            end
            system("rails measure:#{script_type}[#{size},#{file_type},1,#{n_lines}]")
            system("rails measure:#{script_type}[#{size},#{file_type},#{n_lines / 2},#{n_lines}]")
            system("rails measure:#{script_type}[#{size},#{file_type},#{n_lines},#{n_lines}]")
          end
        end
      end
    end
  end

  task :enum, %i[size type index max] => [:environment] do |_task, args|
    print "enumerator;#{args[:size]};#{args[:index]};#{args[:max]}"
    index = args[:index].to_i
    counter = 0
    profile do
      file = File.new("#{args[:size]}mb_#{args[:type]}.txt")
      file.each do |_line|
        if counter == index - 1
          # puts line
          break
        end

        counter += 1
      end
    end
  end

  task :read_file, %i[size type index max] => [:environment] do |_task, args|
    print "read_file;#{args[:size]};#{args[:index]};#{args[:max]}"
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
      file = File.new("#{args[:size]}mb_#{args[:type]}.txt").readlines
      # puts file[index]
    end
  end

  task :read_chunk, %i[size type index max] => [:environment] do |_task, args|
    print "read_chunk;#{args[:size]};#{args[:index]};#{args[:max]}"
    profile do
      file = File.new("#{args[:size]}mb_#{args[:type]}.txt")
      index = args[:index].to_i
      line_count = 0
      partial_str = ''
      final_line = nil
      iteration = 0
      while buf = file.read(chunk_size)
        iteration += 1
        if iteration == index
          puts buf
          break
        end
        buf.each_line do |l|
          line_count += 1
          if line_count == index
            partial_str += l
            next
          end
          if partial_str.present? && line_count > index
            final_line = partial_str
            # puts final_line
            break
          elsif partial_str.blank?
            next
          end

          final_line = "#{partial_str}#{l}"
          # puts final_line
          break
        end
        if buf.last == "\n"
          final_line = partial_str if partial_str.present?
        else
          line_count -= 1
        end
        break if final_line.present?

        buf.tap { |buf| buf }
      end

      # iteration = 0
      # file.seek(chunk_size * (index - 1))
      # buf = file.read(chunk_size)
      # puts buf
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
