require "test_helper"

class HealthControllerTest < ActionDispatch::IntegrationTest
  test "liveness does not require authentication" do
    get "/up"

    assert_response :success
    assert_equal "ok", response.parsed_body.fetch("status")
    assert_equal "no-store", response.headers.fetch("Cache-Control")
  end

  test "readiness checks the database" do
    get "/ready"

    assert_response :success
    assert_equal({ "status" => "ready", "database" => "ok" }, response.parsed_body)
  end

  test "readiness fails closed without exposing the exception" do
    failing = ->(*) { raise "connection details" }

    ActiveRecord::Base.connection.stub(:select_value, failing) do
      get "/ready"
    end

    assert_response :service_unavailable
    assert_equal({ "status" => "unavailable" }, response.parsed_body)
    assert_not_includes response.body, "connection details"
  end
end
