visit settings_path

cancel_subscription

expect(page).to have_text "Subscription canceled"

def cancel_subscription
  click_link "Cancel subscription"
  fill_in "cancellation_reason", with: "I didn't like it"
  click_button "Confirm subscription cancelation"
end
