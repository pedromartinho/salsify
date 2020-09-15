namespace :pre_processing do
  chunk_size = 4096
  buf = ''
  file = File.new(ENV['FILE_NAME'])
  ####################################################################################################
  # Create File
  #
  # Script Description
  ### Used for the creation of a 1 GB file text file
  ####################################################################################################

  task file: :environment do
    file_db = FileDetail.find_by(name: ENV['FILE_NAME'])
    if file_db.nil?
      file_db = FileDetail.create!(name: ENV['FILE_NAME'])
    else
      # file_db.chunk_infos.each(&:delete)
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

      # ChunkInfo.create!(
      #   chunk_number:     chunk_count,
      #   file_detail_id:   file_db.id,
      #   last_line_number: line_count
      # )
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
