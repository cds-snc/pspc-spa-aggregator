require 'test_helper'

class ProcurementsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get api_v1_procurements_url, as: :json
    assert_response :success
  end
end
