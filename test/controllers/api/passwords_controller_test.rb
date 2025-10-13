require "test_helper"

module Api
  class PasswordsControllerTest < ActionDispatch::IntegrationTest
    def setup
      @user = User.create!(
        email: "test@example.com",
        password: "password123",
        name: "Test User"
      )
      @token = JWT.encode(
        { sub: @user.id, exp: 24.hours.from_now.to_i },
        Rails.application.credentials.devise[:jwt_secret_key]
      )
      @auth_headers = { "Authorization" => "Bearer #{@token}" }
    end

    # Index action tests
    test "index returns user's passwords" do
      password1 = @user.passwords.create!(title: "GitHub", password_encrypted: "enc1")
      password2 = @user.passwords.create!(title: "GitLab", password_encrypted: "enc2")

      get api_passwords_url, headers: @auth_headers
      assert_response :success

      json_response = JSON.parse(response.body)
      assert_equal 2, json_response.length
    end

    test "index does not return other users' passwords" do
      other_user = User.create!(email: "other@example.com", password: "password123", name: "Other")
      @user.passwords.create!(title: "My Password", password_encrypted: "enc1")
      other_user.passwords.create!(title: "Other Password", password_encrypted: "enc2")

      get api_passwords_url, headers: @auth_headers
      assert_response :success

      json_response = JSON.parse(response.body)
      assert_equal 1, json_response.length
      assert_equal "My Password", json_response.first["title"]
    end

    test "index with empty password list" do
      get api_passwords_url, headers: @auth_headers
      assert_response :success

      json_response = JSON.parse(response.body)
      assert_equal 0, json_response.length
    end

    test "index orders by recent" do
      password1 = @user.passwords.create!(title: "First", password_encrypted: "enc1")
      sleep 0.01
      password2 = @user.passwords.create!(title: "Second", password_encrypted: "enc2")

      get api_passwords_url, headers: @auth_headers
      assert_response :success

      json_response = JSON.parse(response.body)
      assert_equal "Second", json_response.first["title"]
      assert_equal "First", json_response.last["title"]
    end

    test "index with search parameter" do
      @user.passwords.create!(title: "GitHub Account", password_encrypted: "enc1")
      @user.passwords.create!(title: "GitLab Account", password_encrypted: "enc2")
      @user.passwords.create!(title: "Facebook", password_encrypted: "enc3")

      get api_passwords_url, params: { search: "Git" }, headers: @auth_headers
      assert_response :success

      json_response = JSON.parse(response.body)
      assert_equal 2, json_response.length
    end

    test "index with domain filter" do
      @user.passwords.create!(title: "GitHub", password_encrypted: "enc1", domain: "github.com")
      @user.passwords.create!(title: "GitLab", password_encrypted: "enc2", domain: "gitlab.com")

      get api_passwords_url, params: { domain: "github.com" }, headers: @auth_headers
      assert_response :success

      json_response = JSON.parse(response.body)
      assert_equal 1, json_response.length
      assert_equal "GitHub", json_response.first["title"]
    end

    test "index without authentication returns 401" do
      get api_passwords_url
      assert_response :unauthorized
    end
  end
end
