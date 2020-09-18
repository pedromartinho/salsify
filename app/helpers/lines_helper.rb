module LinesHelper
  #################################################################################################
  # Function - Is Integer
  #
  # Description
  ### INPUT: string for validation
  ### Verify if a given string is a valid integer or not. It it is, returns the integer it
  ### corresponds, if not, returns false
  #################################################################################################
  def is_integer?(str)
    line_number = Integer(str)
    line_number.positive? ? line_number : false
  rescue StandardError => e
    false
  end

  #################################################################################################
  # Function - Is Integer
  #
  # Description
  ### INPUT: file - IO object from where should start reading the file
  ###        counter - line number you star in that part of the file
  ###        idx - line number to retrieve
  ### Verify if a given string is a valid integer or not. It it is, returns the integer it
  ### corresponds, if not, returns false
  #################################################################################################
  def findLine(file, counter, idx)
    line_content = nil
    file.each do |line|
      puts line
      if counter == idx

        line_content = line
        break
      end
      counter += 1
    end
    line_content
  end
end
