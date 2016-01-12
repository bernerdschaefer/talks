visit account_path

expect(page).to have_css(".plan.active", text: "Free")
expect(page).to have_text "Upgrade to Pro"

find(".upgrade").click

expect(page).not_to have_text "Upgrade to Pro"
expect(page).to have_css(".plan.active", text: "Pro")
