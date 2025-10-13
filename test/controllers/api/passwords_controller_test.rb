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
        { sub: @user.id, scp: 'user', exp: 24.hours.from_now.to_i, jti: SecureRandom.uuid },
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
      assert_equal 2, json_response["data"].length
      assert json_response["pagination"].present?
    end

    test "index does not return other users' passwords" do
      other_user = User.create!(email: "other@example.com", password: "password123", name: "Other")
      @user.passwords.create!(title: "My Password", password_encrypted: "enc1")
      other_user.passwords.create!(title: "Other Password", password_encrypted: "enc2")

      get api_passwords_url, headers: @auth_headers
      assert_response :success

      json_response = JSON.parse(response.body)
      assert_equal 1, json_response["data"].length
      assert_equal "My Password", json_response["data"].first["title"]
    end

    test "index with empty password list" do
      get api_passwords_url, headers: @auth_headers
      assert_response :success

      json_response = JSON.parse(response.body)
      assert_equal 0, json_response["data"].length
    end

    test "index orders by recent" do
      password1 = @user.passwords.create!(title: "First", password_encrypted: "enc1")
      sleep 0.01
      password2 = @user.passwords.create!(title: "Second", password_encrypted: "enc2")

      get api_passwords_url, headers: @auth_headers
      assert_response :success

      json_response = JSON.parse(response.body)
      assert_equal "Second", json_response["data"].first["title"]
      assert_equal "First", json_response["data"].last["title"]
    end

    test "index with search parameter" do
      @user.passwords.create!(title: "GitHub Account", password_encrypted: "enc1")
      @user.passwords.create!(title: "GitLab Account", password_encrypted: "enc2")
      @user.passwords.create!(title: "Facebook", password_encrypted: "enc3")

      get api_passwords_url, params: { search: "Git" }, headers: @auth_headers
      assert_response :success

      json_response = JSON.parse(response.body)
      assert_equal 2, json_response["data"].length
    end

    test "index with domain filter" do
      @user.passwords.create!(title: "GitHub", password_encrypted: "enc1", domain: "github.com")
      @user.passwords.create!(title: "GitLab", password_encrypted: "enc2", domain: "gitlab.com")

      get api_passwords_url, params: { domain: "github.com" }, headers: @auth_headers
      assert_response :success

      json_response = JSON.parse(response.body)
      assert_equal 1, json_response["data"].length
      assert_equal "GitHub", json_response["data"].first["title"]
    end

    test "index without authentication returns 401" do
      get api_passwords_url
      assert_response :unauthorized
    end

    # Show action tests
    test "show returns password details" do
      password = @user.passwords.create!(
        title: "GitHub",
        username: "user@example.com",
        password_encrypted: "enc1",
        domain: "github.com",
        notes: "My notes"
      )

      get api_password_url(password), headers: @auth_headers
      assert_response :success

      json_response = JSON.parse(response.body)
      assert_equal "GitHub", json_response["title"]
      assert_equal "user@example.com", json_response["username"]
      assert_equal "github.com", json_response["domain"]
    end

    test "show with invalid id returns 404" do
      get api_password_url(99999), headers: @auth_headers
      assert_response :not_found
    end

    test "show with other user's password returns 404" do
      other_user = User.create!(email: "other@example.com", password: "password123", name: "Other")
      other_password = other_user.passwords.create!(title: "Other", password_encrypted: "enc1")

      get api_password_url(other_password), headers: @auth_headers
      assert_response :not_found
    end

    test "show without authentication returns 401" do
      password = @user.passwords.create!(title: "Test", password_encrypted: "enc1")
      get api_password_url(password)
      assert_response :unauthorized
    end

    # Update action tests
    test "update with valid data" do
      password = @user.passwords.create!(title: "Old Title", password_encrypted: "enc1")

      patch api_password_url(password),
        params: { password: { title: "New Title" } },
        headers: @auth_headers

      assert_response :success
      password.reload
      assert_equal "New Title", password.title
    end

    test "update with invalid data returns 422" do
      password = @user.passwords.create!(title: "Test", password_encrypted: "enc1")

      patch api_password_url(password),
        params: { password: { title: "" } },
        headers: @auth_headers

      assert_response :unprocessable_entity
      json_response = JSON.parse(response.body)
      assert json_response["errors"].present?
    end

    test "update other user's password returns 404" do
      other_user = User.create!(email: "other@example.com", password: "password123", name: "Other")
      other_password = other_user.passwords.create!(title: "Other", password_encrypted: "enc1")

      patch api_password_url(other_password),
        params: { password: { title: "Hacked" } },
        headers: @auth_headers

      assert_response :not_found
    end

    test "update without authentication returns 401" do
      password = @user.passwords.create!(title: "Test", password_encrypted: "enc1")
      patch api_password_url(password), params: { password: { title: "New" } }
      assert_response :unauthorized
    end

    # Destroy action tests
    test "destroy with valid password" do
      password = @user.passwords.create!(title: "To Delete", password_encrypted: "enc1")

      assert_difference "@user.passwords.count", -1 do
        delete api_password_url(password), headers: @auth_headers
      end

      assert_response :success
      json_response = JSON.parse(response.body)
      assert_equal "Password deleted successfully", json_response["message"]
    end

    test "destroy other user's password returns 404" do
      other_user = User.create!(email: "other@example.com", password: "password123", name: "Other")
      other_password = other_user.passwords.create!(title: "Other", password_encrypted: "enc1")

      delete api_password_url(other_password), headers: @auth_headers
      assert_response :not_found
    end

    test "destroy with invalid id returns 404" do
      delete api_password_url(99999), headers: @auth_headers
      assert_response :not_found
    end

    test "destroy without authentication returns 401" do
      password = @user.passwords.create!(title: "Test", password_encrypted: "enc1")
      delete api_password_url(password)
      assert_response :unauthorized
    end
  end
end
