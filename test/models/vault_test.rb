require "test_helper"

class VaultTest < ActiveSupport::TestCase
  def setup
    @user = User.create!(
      email: "test@example.com",
      password: "password123",
      password_confirmation: "password123"
    )
  end

  test "vault belongs to user" do
    vault = Vault.new
    assert_not vault.valid?
    assert_includes vault.errors[:user], "must exist"
  end

  test "vault is valid with a user" do
    vault = Vault.new(user: @user)
    assert vault.valid?
  end

  test "user_id must be unique" do
    Vault.create!(user: @user)
    duplicate_vault = Vault.new(user: @user)

    assert_not duplicate_vault.valid?
    assert_includes duplicate_vault.errors[:user_id], "has already been taken"
  end

  test "user can have one vault" do
    vault = Vault.create!(user: @user)
    assert_equal vault, @user.vault
  end

  test "destroying user destroys associated vault" do
    vault = Vault.create!(user: @user)
    assert_difference('Vault.count', -1) do
      @user.destroy
    end
  end
end
