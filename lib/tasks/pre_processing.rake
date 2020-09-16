namespace :pre_processing do
  chunk_size = 4096
  buf = ''

  ####################################################################################################
  # Create File
  #
  # Script Description
  ### Used for the creation of a 1 GB file text file
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
    new_line = false
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

  task all: :environment do
    all_sizes = [0.1, 0.5, 1, 5, 10, 50, 100, 500]
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
        new_line = false
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
