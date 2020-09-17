require "#{Rails.root}/app/helpers/profile_helper"
include ProfileHelper
require 'benchmark'

namespace :measure do
  #################################################################################################
  # Script - Measure All
  #
  # Description
  ### Tests all the created algorithms over all the created files and prints the results as the
  ### scripts are running. This is the function used to get all the data to take the conclusions
  ### presented in the readme file
  #################################################################################################
  task all: :environment do
    all_file_types = ['long_line', 'medium_line', 'short_line', 'only_paragraphs']
    all_script_types = ['read_lines', 'each_line', 'final']
    puts 'Pre Processing all files...'
    system('rails pre_processing:all')
    puts 'Star getting the metric values...'
    print "script;file_name;file_size;index;max;freed_objs;time;used_memory\n"
    3.times do
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

  #################################################################################################
  # Script - Measure Each Line
  #
  # Description
  ### This script uses the  COMPLETE
  #################################################################################################
  task :each_line, %i[size type index max] => [:environment] do |_task, args|
    file_name = "#{args[:size]}mb_#{args[:type]}.txt"
    print "each_line;#{file_name};#{args[:size]};#{args[:index]};#{args[:max]}"
    line_memory = nil

    index = args[:index].to_i
    counter = 0
    profile do
      file = File.new(file_name)
      file.each do
        break if counter == index - 1

        counter += 1
      end
    end
  end

  #################################################################################################
  # Script - Measure Read File
  #
  # Description
  ### This script uses the readlines method that - COMPLETE
  #################################################################################################
  task :read_lines, %i[size type index max] => [:environment] do |_task, args|
    file_name = "#{args[:size]}mb_#{args[:type]}.txt"
    print "read_lines;#{file_name};#{args[:size]};#{args[:index]};#{args[:max]}"
    index = args[:index].to_i
    profile do
      File.new(file_name).readlines[index]
    end
  end

  #################################################################################################
  # Script - Measure Final
  #
  # Description
  ### Uses information obtained in the file pre-processment to reach a solution faster and using
  ### less memory. This is achieved moving the file pointer to a zone of the file where the line
  ### number is still lower than the line we want to get but it much closer. After reaching this
  ### point, will use the each method for the file that will read line by line until it reachs the
  ### desired line
  #################################################################################################
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

      file.each do |_line|
        break if counter == index

        counter += 1
      end
    end
  end
end
