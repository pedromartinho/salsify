module ProfileHelper
  # bytes of a megabyte
  def one_megabyte
    1024 * 1024
  end

  # chunk size considered for the pre-processing of the file
  def chunk_size
    4096
  end

  # all sizes cosidered in Mb in an array
  def all_sizes
    [0.1, 0.5, 1, 5, 10]
  end

  #################################################################################################
  # Function - Profile
  #
  # Description
  ### Profiles the memory, time and number of freed objects by the Garbage Collector from the begin
  ### and the finish of a script
  #################################################################################################
  def profile
    profile_memory do
      profile_time do
        profile_gc do
          yield
        end
      end
    end
  end

  #################################################################################################
  # Function - Profile Memory
  #
  # Description
  ### Profiles the memory used from the begin and the finish of the script
  #################################################################################################
  def profile_memory
    memory_usage_before = `ps -o rss= -p #{Process.pid}`.to_i
    yield
    memory_usage_after = `ps -o rss= -p #{Process.pid}`.to_i

    used_memory = ((memory_usage_after - memory_usage_before) / 1024.0).round(2)
    puts "Memory usage: #{used_memory} MB"
    # print ";#{used_memory}\n"
  end

  #################################################################################################
  # Function - Profile Time
  #
  # Description
  ### Profiles the time taken in seconds from the begin and the finish of a script
  #################################################################################################
  def profile_time
    time_elapsed = Benchmark.realtime do
      yield
    end

    puts "Time: #{time_elapsed.round(3)} seconds"
    # print ";#{time_elapsed.round(3)}"
  end

  #################################################################################################
  # Function - Profile GC
  #
  # Description
  ### Profiles the number of freed objects by the Garbage Collector from the begin and the finish
  ### of a script
  #################################################################################################
  def profile_gc
    GC.start
    before = GC.stat(:total_freed_objects)
    yield
    GC.start
    after = GC.stat(:total_freed_objects)

    puts "Objects Freed: #{after - before}"
    # print ";#{after - before}"
  end
end
