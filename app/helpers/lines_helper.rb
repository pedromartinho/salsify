module LinesHelper
  include ProfileHelper

  def one_megabyte
    one_megabyte
  end

  def chunk_size
    chunk_size
  end

  def all_sizes
    all_sizes
  end

  def is_integer?(str)
    line_number = Integer(str)
    line_number.positive? ? line_number : false
  rescue StandardError => e
    false
  end
end
