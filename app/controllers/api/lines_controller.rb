require "#{Rails.root}/app/helpers/lines_helper"
require "#{Rails.root}/app/helpers/profile_helper"

module Api
  class LinesController < ApplicationController
    include LinesHelper
    include ProfileHelper

    before_action :ensure_self_params, only: %i[show]

    ####################################################################################################
    # GET /lines/:line_number

    # Description
    ### INPUT: line_number - Number of the line we want to read from the file
    ### Endpoint to get the line content from an imutable file. The approach is to check the file
    ### average number of char per line, if the number lower than 512 (buffer size used on IO.each
    ### method) and the line number is lower than 10000, the algorithm will start reading the file from
    ### the beginning. If not, it will go to the database and check from which point in the file should
    ### it start reading.
    ####################################################################################################

    def show
      file = File.new(ENV['FILE_NAME'])
      line_content = nil

      counter = 1

      if @line_number > ENV['FILE_LINES'].to_i
        return render json: {
          message: "Line number is bigger than the total number of lines in the file (#{ENV['FILE_LINES']})!"
        }, status: 413
      end

      if @line_number < 10_000 && ENV['FILE_SIZE'].to_i / ENV['FILE_LINES'].to_i < 512
        line_content = findLine(file, counter, @line_number)
      else
        fd = FileDetail.find_by(name: ENV['FILE_NAME'])
        ci = ChunkInfo.where(file_detail_id: fd.id).where('last_line_number < ?', @line_number).last

        chunk_steps = ci.present? ? ci.chunk_number : 0
        counter = ci.last_line_number if ci.present?
        file.seek(chunk_steps * chunk_size)

        line_content = findLine(file, counter, @line_number)
      end

      render json: {
        message: 'Found it!',
        line:    line_content.tr("\n", '')
      }, status: 200
    end

    private

    def self_params
      params.permit(:id)
    end

    def ensure_self_params
      @line_number = is_integer?(self_params[:id])

      unless @line_number
        render json: {
          message: 'Line number must be an integer!'
        }, status: 400
      end
    end
  end
end
