require "test_helper"

class IndexTest < ActionDispatch::IntegrationTest
  test "#index view has expected elements" do
    get(api_v1_root_path)

    assert_response :success
    assert_select "label", "Filename"
    assert_select "label", "Number of lines"
    assert_select "label", "Search keywords"
    assert_select "input[type=\"submit\"]"
  end
end