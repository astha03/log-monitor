require "test_helper"

class RoutesTest < ActionDispatch::IntegrationTest
  def setup 
    LogViewer.any_instance.stubs(:fetch_log).returns(["line_one", "line_two"])
  end

  test "root should route to index" do
    get api_v1_root_path

    assert_response :success
    assert_equal "index", @controller.action_name
  end

  test "/logs should route to get_log" do
    get api_v1_logs_path, params: {"filename" => "test_log"}
    
    assert_response :success
    assert_equal "get_log", @controller.action_name
  end
end
