feature "foo" do
  scenario "Admin makes a user an admin" do
    login_as_admin
    user = create(:user)

    visit users_path
    users_page = UsersPage.new

    expect(users_page).not_to have_admin(user)

    users_page.show_edit_form_for(user)
    users_page.make_admin
    # users_page.change_role_to("Admin")

    expect(users_page).to have_admin(user)
  end

  def login_as_admin
    # ...
  end
end

class UsersPage
  def has_admin?(user)
    within "#user_#{user.id}" do
      has_text?("Admin")
    end
  end

  def make_admin
    update_role("Admin")
  end

  private

  def update_role(role)
    click role
    click "Update"
  end
end
