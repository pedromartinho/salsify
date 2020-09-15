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
      "DELETE FROM chunk_infos WHERE chunk_infos.file_detail_id = #{file_db.id};"
      ActiveRecord::Base.connection.execute(sql)
    end
    line_count = 0
    chunk_count = 0
    while buf = file.read(chunk_size)
      chunk_count += 1
      line_count += num_lines(buf)

      sql += "INSERT INTO chunk_infos (chunk_number, file_detail_id, last_line_number) VALUES #{chunk_count},#{file_db.id},#{line_count};"

      # ChunkInfo.create!(
      #   chunk_number:     chunk_count,
      #   file_detail_id:   file_db.id,
      #   last_line_number: line_count
      # )
      if chunk_count % 1000 == 0
        ActiveRecord::Base.connection.execute(sql)
        sql = ''
      end

      buf.tap { |buf| buf }
    end
    ActiveRecord::Base.connection.execute(sql) if sql.present?

    file_db.update!(
      size:         file_db.chunk_infos.count * chunk_size,
      lines_number: line_count
    )
  end

  private

  def num_lines(buffer)
    lines = buffer.split("\n")
    num_lines = lines.length
    if num_lines == 1 && !buffer.include?("\n")
      num_lines = 0
    else
      num_lines = lines.length
      num_lines += 1 if !buffer.first == "\n"
      num_lines += 1 if !buffer.last == "\n"
    end
    num_lines
  end
end
