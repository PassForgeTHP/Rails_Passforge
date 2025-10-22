require "test_helper"

class ContactsControllerTest < ActionDispatch::IntegrationTest
  test "should post create" do
    post contacts_url, params: { email: "test@example.com", subject: "Test subject", content: "This is a test content with enough length." }
    assert_response :success
  end
end
