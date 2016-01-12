visit account_path
account_page = AccountPage.new

expect(account_page).to have_active_plan("Free")
expect(account_page).to have_upgrade_prompt

account_page.upgrade

expect(account_page).not_to have_upgrade_prompt
expect(account_page).to have_active_plan("Pro")

class AccountPage
  def has_active_plan?(name)
    has_css?(".plan.active", text: name)
  end

  def has_upgrade_prompt?
    has_text? "Upgrade to Pro"
  end

  def upgrade
    find(".upgrade").click
  end
end
