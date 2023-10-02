require "test_helper"

class Api::V1::LogsControllerTest < ActionDispatch::IntegrationTest
  def setup 
    @content = ["line_one", "line_two"]
    LogViewer.any_instance.stubs(:fetch_log).returns(@content)
  end

  test "#get_log returns error if filename is missing" do
    assert_raise ActionController::ParameterMissing do
      get api_v1_logs_path, params: {}
    end
  end

  test "#get_log returns error if invalid parameter is passed" do
    assert_raise ActionController::UnpermittedParameters do
      get(
        api_v1_logs_path, 
        params: {"filename" => "test_log", "some_arg" => "some_value"}
      )
    end
  end

  test "#get_log returns log entries when valid params are passed" do
    filename = "test_log"
    get(
      api_v1_logs_path, 
      params: {"filename" => filename , "n" => 2, "filter" => "line"}
    )

    assert_response :success
    assert_includes @response.body, filename
    assert_includes @response.body, @content[0]
    assert_includes @response.body, @content[1]
  end
end
