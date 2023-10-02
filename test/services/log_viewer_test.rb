require "test_helper"

class LogViewerTest < ActiveSupport::TestCase
  test "#initialize uses default filepath if not provided" do
    log_viewer = LogViewer.new(filename: "test_log")
    assert_equal LogViewer::FILEPATH, log_viewer.filepath
  end
  
  test "#initialize uses default number of lines if not provided or is blank" do
    log_viewer = LogViewer.new(filename: "test_log")
    assert_equal LogViewer::NUM_LINES, log_viewer.num_lines

    log_viewer = LogViewer.new(filename: "test_log", num_lines: nil)
    assert_equal LogViewer::NUM_LINES, log_viewer.num_lines

    log_viewer = LogViewer.new(filename: "test_log", num_lines: "")
    assert_equal LogViewer::NUM_LINES, log_viewer.num_lines
  end

  test "#fetch_log returns empty array if number of lines is not greater than 0" do
    log_viewer = LogViewer.new(filename: "syslog", num_lines: 0)
    content = log_viewer.fetch_log
    assert_equal [], content

    log_viewer = LogViewer.new(filename: "syslog", num_lines: -2)
    content = log_viewer.fetch_log
    assert_equal [], content
  end

  test "#fetch_log reads file when file is bigger than buffer size" do
    log_viewer = LogViewer.new(filename: "syslog", num_lines: 20)
    content = log_viewer.fetch_log

    assert_equal 20, content.length
  end

  test "#fetch_log reads file when file is smaller than buffer size" do
    expected = [
      "This is line three",
      "This is line two",
      "This is line one"
    ]

    log_viewer = LogViewer.new(
      filename: "test_log.log", 
      filepath: Rails.root.to_s + "/test/data/", 
      num_lines: 3
    )
    content = log_viewer.fetch_log

    assert_equal expected, content
  end

  test "#fetch_log returns correct result when num_lines > total number of lines" do
    expected = [
      "This is line three",
      "This is line two",
      "This is line one"
    ]
    
    log_viewer = LogViewer.new(
      filename: "test_log.log", 
      filepath: Rails.root.to_s + "/test/data/", 
      num_lines: 5
    )
    content = log_viewer.fetch_log

    assert_equal expected, content
  end

  test "#fetch_log returns correct result when num_lines < total number of lines" do
    expected = [
      "This is line three",
      "This is line two",
    ]
    
    log_viewer = LogViewer.new(
      filename: "test_log.log", 
      filepath: Rails.root.to_s + "/test/data/", 
      num_lines: 2
    )
    content = log_viewer.fetch_log

    assert_equal expected, content
  end

  test "#fetch_log filters based on provided search text" do
    expected = [
      "This is line two",
    ]
    
    log_viewer = LogViewer.new(
      filename: "test_log.log", 
      filepath: Rails.root.to_s + "/test/data/", 
      num_lines: 5,
      search_text: "two"
    )
    content = log_viewer.fetch_log

    assert_equal expected, content
  end
end
