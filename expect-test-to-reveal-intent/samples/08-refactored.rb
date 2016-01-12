scenario "Admin makes a user an admin" do
  admin = create(:admin)
  user = create(:user)

  visit users_path
  users_page = UsersPage.new

  expect(users_page).not_to have_admin(user)

  users_page.edit(user)

  check "Admin"
  click_on "Update"

  expect(users)page).to have_admin(user)
end

factory :user
  factory :admin
    admin true
  end
end

class UsersPage
  def has_admin?(user)
    within_user user do
      has_text? "Admin"
    end
  end

  def edit(user)
    within_user user do
      click_on "Edit"
    end
  end
end
