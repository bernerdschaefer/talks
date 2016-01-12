visit account_path
plan_page = PlanPage.new

expect(plan_page).to have_active_plan("Free")
expect(plan_page).to be_upgradable

plan_page.upgrade_plan

expect(plan_page).not_to be_upgradable
expect(plan_page).to have_active_plan("Pro")

class PlanPage
  def is_upgradable?
    has_text?("Upgrade to Pro")
  end

  def has_active_plan?(plan)
    has_css?(".plan.active", text: plan)
  end

  def upgrade_plan
    find(".upgrade").click
  end
end
