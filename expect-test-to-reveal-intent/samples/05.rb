visit settings_path

click_link "Cancel subscription"
fill_in "cancellation_reason", with: "I didn't like it"
click_button "Confirm subscription cancelation"

expect(page).to have_text "Subscription canceled"
