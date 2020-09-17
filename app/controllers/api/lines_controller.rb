require "#{Rails.root}/app/helpers/lines_helper"

module Api
  class LinesController < ApplicationController
    include LinesHelper

    before_action :ensure_self_params, only: %i[show]

    ####################################################################################################
    # GET /lines/:line_number

    # Description
    ### Endpoint to get the line content from an imutable file
    ####################################################################################################

    def show
      file = File.new(ENV['FILE_NAME'])
      line_content = nil

      if @line_number > ENV['FILE_LINES'].to_i
        return render json: {
          message: 'Line number is bigger than the total number of lines in the file!'
        }, status: 413
      end
      
      if @line_number < 100 && ENV['FILE_SIZE'].to_i / ENV['FILE_LINES'].to_i < 1024
        file.each_with_index do |line, idx|
          if idx == @line_number
            line_content = line
            break
          end
        end
      else
        fd = FileDetail.find_by(name: ENV['FILE_NAME'])
        ci = ChunkInfo.where(file_detail_id: fd.id).where('last_line_number < ?', index).last

        chunk_steps = ci.present? ? ci.chunk_number : 0
        counter = ci.present? ? ci.last_line_number : 1
        file.seek(chunk_steps * chunk_size)

        file.each do |line|
          if counter == @line_number
            puts line
            break
          end

          counter += 1
        end
      end

      render json: {
        message: 'Found it!',
        line:    line_content
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
