visit settings_path

cancel_subscription(reason: "I didn't like it")

expect(page).to have_canceled_subscription

def have_canceled_subscription
  have_text "Subscription canceled"
end

def cancel_subscription(reason:)
  click_link "Cancel subscription"
  fill_in "cancellation_reason", with: reason
  click_button "Confirm subscription cancelation"
end
