require "test_helper"

class PasswordTest < ActiveSupport::TestCase
  def setup
    @user = User.create!(
      email: "test@example.com",
      password: "password123",
      name: "Test User"
    )
    @password = @user.passwords.build(
      title: "Test Password",
      password_encrypted: "encrypted_data_here"
    )
  end

  test "should be valid with valid attributes" do
    assert @password.valid?
  end

  test "should require title" do
    @password.title = nil
    assert_not @password.valid?
    assert_includes @password.errors[:title], "can't be blank"
  end

  test "should require password_encrypted" do
    @password.password_encrypted = nil
    assert_not @password.valid?
    assert_includes @password.errors[:password_encrypted], "can't be blank"
  end

  test "should require user" do
    @password.user = nil
    assert_not @password.valid?
  end

  test "should enforce maximum length for title" do
    @password.title = "a" * 201
    assert_not @password.valid?
    assert_includes @password.errors[:title], "is too long (maximum is 200 characters)"
  end

  test "should enforce maximum length for notes" do
    @password.notes = "a" * 5001
    assert_not @password.valid?
    assert_includes @password.errors[:notes], "is too long (maximum is 5000 characters)"
  end

  test "should allow blank username" do
    @password.username = ""
    assert @password.valid?
  end

  test "should allow blank domain" do
    @password.domain = ""
    assert @password.valid?
  end

  test "should allow blank notes" do
    @password.notes = ""
    assert @password.valid?
  end

  test "should belong to user" do
    assert_respond_to @password, :user
  end

  test "should order by recent" do
    password1 = @user.passwords.create!(title: "First", password_encrypted: "enc1")
    password2 = @user.passwords.create!(title: "Second", password_encrypted: "enc2")

    assert_equal [password2, password1], Password.recent.to_a
  end

  test "should filter by domain" do
    password1 = @user.passwords.create!(title: "GitHub", password_encrypted: "enc1", domain: "github.com")
    password2 = @user.passwords.create!(title: "GitLab", password_encrypted: "enc2", domain: "gitlab.com")

    assert_equal [password1], Password.by_domain("github.com").to_a
  end
end
