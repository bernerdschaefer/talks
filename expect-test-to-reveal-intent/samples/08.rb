scenario "Admin makes a user an admin" do
  admin = create(:user, admin: true)
  user = create(:user)

  visit users_path

  within "#user_#{user.id}" do
    expect(page).not_to have_text("Admin")
    click_on "Edit"
  end

  check "Admin"
  click_on "Update"

  within "#user_#{user.id}" do
    expect(page).to have_text("Admin")
  end
end
