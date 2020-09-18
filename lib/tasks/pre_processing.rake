require "#{Rails.root}/app/helpers/profile_helper"
include ProfileHelper

namespace :pre_processing do
  ####################################################################################################
  # Script - Pre Processing File
  #
  # Description
  ### First, this script will clean the data from the database. After that, it will read the file
  ### chunk by chunk and store the last line number he spoted in each chunkWill read the file chunk
  ### by chunk and store in the database.
  ####################################################################################################

  task file: :environment do
    file = File.new(ENV['FILE_NAME'])
    file_db = FileDetail.find_by(name: ENV['FILE_NAME'])
    if file_db.nil?
      file_db = FileDetail.create!(name: ENV['FILE_NAME'])
    else
      sql = "DELETE FROM chunk_infos WHERE chunk_infos.file_detail_id = #{file_db.id};"
      ActiveRecord::Base.connection.execute(sql)
    end
    line_count = 1
    chunk_count = 0
    time_now = Time.now
    values = []
    while buf = file.read(chunk_size)
      chunk_count += 1
      line_count += buf.count "\n"

      values.push("(#{chunk_count},#{file_db.id},#{line_count},'#{time_now}','#{time_now}')")

      if chunk_count % 1000 == 0
        sql = "INSERT INTO chunk_infos (chunk_number, file_detail_id, last_line_number, created_at, updated_at) VALUES #{values.join(',')};"
        ActiveRecord::Base.connection.execute(sql)
        values = []
      end

      buf.tap { |buf| buf }
    end
    if values.present?
      sql = "INSERT INTO chunk_infos (chunk_number, file_detail_id, last_line_number, created_at, updated_at) VALUES #{values.join(',')};"
      ActiveRecord::Base.connection.execute(sql)
    end

    file_db.update!(
      size:         ENV['FILE_SIZE'],
      lines_number: ENV['FILE_LINES']
    )
  end

  ####################################################################################################
  # Script - Pre Processing File
  #
  # Description
  ### Performs the pre processing method for all the files in the root folder and stores their
  ### information into the database
  ####################################################################################################
  task all: :environment do
    all_file_types = ['long_line', 'medium_line', 'short_line', 'only_paragraphs']
    all_sizes.each do |size|
      all_file_types.each do |file_type|
        file_name = "#{size}mb_#{file_type}.txt"
        file = File.new(file_name)
        file_db = FileDetail.find_by(name: file_name)
        if file_db.nil?
          file_db = FileDetail.create!(name: file_name)
        else
          sql = "DELETE FROM chunk_infos WHERE chunk_infos.file_detail_id = #{file_db.id};"
          ActiveRecord::Base.connection.execute(sql)
        end
        line_count = 1
        chunk_count = 0
        time_now = Time.now
        values = []
        while buf = file.read(chunk_size)
          chunk_count += 1
          line_count += buf.count "\n"

          values.push("(#{chunk_count},#{file_db.id},#{line_count},'#{time_now}','#{time_now}')")

          if chunk_count % 1000 == 0
            sql = "INSERT INTO chunk_infos (chunk_number, file_detail_id, last_line_number, created_at, updated_at) VALUES #{values.join(',')};"
            ActiveRecord::Base.connection.execute(sql)
            values = []
          end

          buf.tap { |buf| buf }
        end
        if values.present?
          sql = "INSERT INTO chunk_infos (chunk_number, file_detail_id, last_line_number, created_at, updated_at) VALUES #{values.join(',')};"
          ActiveRecord::Base.connection.execute(sql)
        end
        file_db.update!(
          size:         file_db.chunk_infos.count * chunk_size,
          lines_number: line_count
        )
      end
    end
  end
end
