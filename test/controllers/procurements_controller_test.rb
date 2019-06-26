require 'test_helper'

class ProcurementsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @procurement = procurements(:one)
  end

  test "should get index" do
    get procurements_url, as: :json
    assert_response :success
  end

  test "should create procurement" do
    assert_difference('Procurement.count') do
      post procurements_url, params: { procurement: {  } }, as: :json
    end

    assert_response 201
  end

  test "should show procurement" do
    get procurement_url(@procurement), as: :json
    assert_response :success
  end

  test "should update procurement" do
    patch procurement_url(@procurement), params: { procurement: {  } }, as: :json
    assert_response 200
  end

  test "should destroy procurement" do
    assert_difference('Procurement.count', -1) do
      delete procurement_url(@procurement), as: :json
    end

    assert_response 204
  end
end
