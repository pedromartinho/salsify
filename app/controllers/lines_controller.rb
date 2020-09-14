class LinesController < ApplicationController
  before_action :ensure_self_params, only: %i[show]

  ####################################################################################################
  # GET /lines/:line_number

  # Description
  ### Endpoint to get the line content from an imutable file
  ####################################################################################################

  def show
    file = File.foreach(ENV['FILE_NAME'])
    line_content = nil
    @line_number -= 1
    max_line = 1
    file.each_with_index do |line, idx|
      if idx == @line_number
        line_content = line
        break
      end
    end

    if line_content.present?
      render json: {
        message: 'Found it!',
        line:    line_content
      }, status: 200
    else
      render json: {
        message: 'Line number is bigger than the total number of lines in the file!'
      }, status: 413
    end
  end
  
  # def first_solution
  #   file = File.foreach(ENV['FILE_NAME'])
  #   line_content = nil
  #   @line_number -= 1
  #   max_line = 1
  #   file.each_with_index do |line, idx|
  #     if idx == @line_number
  #       line_content = line
  #       break
  #     end
  #   end

  #   if line_content.present?
  #     render json: {
  #       message: 'Found it!',
  #       line:    line_content
  #     }, status: 200
  #   else
  #     render json: {
  #       message: 'Line number is bigger than the total number of lines in the file!'
  #     }, status: 413
  #   end
  # end

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

  def is_integer?(str)
    line_number = Integer(str)
    line_number.positive? ? line_number : false
  rescue StandardError => e
    false
  end
end
