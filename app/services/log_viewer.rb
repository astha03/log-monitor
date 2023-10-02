class LogViewer
  BUFFER_SIZE = 8192 # 8 KB 
  NUM_LINES = 10
  FILEPATH = "/var/log/"

  def initialize(filename:, filepath: FILEPATH, num_lines: NUM_LINES, search_text: nil)
    @filename = filename
    @filepath = filepath
    @num_lines = num_lines.blank? ? NUM_LINES : num_lines.to_i
    @search_text = search_text
  end

  attr_accessor :filename, :filepath, :num_lines, :search_text

  def fetch_log
    return [] if @num_lines <= 0

    full_file_path = "#{filepath}#{@filename}"
    file_size = File.size(full_file_path)
    file = File.new(full_file_path)
    
    if BUFFER_SIZE < file_size
      lines_read = 0
      file.seek(0, IO::SEEK_END) 

      content = []
      while lines_read < @num_lines
        if file.pos > BUFFER_SIZE
          file.seek(-BUFFER_SIZE, IO::SEEK_CUR)
          buffer = file.read(BUFFER_SIZE)

          first_newline_idx = buffer.index("\n")
          buffer = buffer[first_newline_idx + 1..-1]
          file.seek(-BUFFER_SIZE, IO::SEEK_CUR)
          file.seek(first_newline_idx + 1, IO::SEEK_CUR)

          num_lines, lines = process_buffer_content(buffer)
          
          lines_read += num_lines
          content = lines + content
        else # last read 
          file.seek(-file.pos, IO::SEEK_CUR)
          buffer = file.read(file.pos)

          num_lines, lines = process_buffer_content(buffer)

          lines_read += num_lines
          content = lines + content

          break
        end
      end
    else
      file.rewind
      lines = file.readlines
      content = filter_content(lines)
    end

    file.rewind
    file.close

    start_idx = @num_lines > content.length ? 0 : content.length-@num_lines
    content[start_idx..-1].map(&:chomp).reverse
  end

  private

  def process_buffer_content(buffer)
    lines = buffer.split("\n")
    filtered_lines = filter_content(lines)

    [filtered_lines.length, filtered_lines]
  end

  def filter_content(log_lines)
    return log_lines if @search_text.blank?

    filtered_lines = []
    log_lines.each do |line|
      if line.include?(@search_text)
        filtered_lines << line
      end
    end

    filtered_lines
  end
end
