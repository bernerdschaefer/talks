class: center, middle

# expect(test).to reveal_intent

.footnote[Bernerd Schaefer / Development Director @ thoughtbot]

---

# Feature tests

Also known as:

* End-to-end tests
* Integration tests
* Acceptance tests

---

# High-level

---

# User-focused

---

# RSpec

```ruby
# spec/features/visitor_signs_up_spec.rb

feature "Visitor signs up" do
  scenario "with valid email and password" do
  end

  scenario "with invalid email" do
  end

  scenario "with blank password" do
  end
end
```

---

# Capybara

```ruby
scenario "with valid email and password" do
  visit sign_up_path

  fill_in "Email", with: "b@thoughtbot.com"
  fill_in "Password", with: "let me in"
  click_on "Submit"

  expect(page).to have_text "Signed in"
end
```

---

# The problem

---

# What we intend

```ruby
feature "User creates a subscription" do
  scenario "doesn't create a subscription with an invalid credit card" do
    plan = create_plan
    user = sign_in

    subscribe_with_invalid_credit_card(plan: plan)

    expect(page).to have_credit_card_error
    expect(user).not_to have_active_subscription
  end
end
```

---

# What we write

```ruby
feature "User creates a subscription" do
  scenario "doesn't create a subscription with an invalid credit card" do
    plan = create(:plan)
    user = create(:user)
    visit root_path(as: user)
    visit new_checkout_path(plan)

    credit_card_expires_on = Time.now.advance(years: 1)
    month_selection = credit_card_expires_on.strftime("%-m - %B")
    year_selection = credit_card_expires_on.strftime("%Y")

    fill_in "Card Number", with: "invalid credit card number"
    select month_selection, from: "date[month]"
    select year_selection, from: "date[year]"
    fill_in "CVC", with: "333"
    click_button "Submit Payment"

    expect(page).to have_text(I18n.t("checkout.problem_with_card", message: ""))
    expect(user.subscription).not_to be_present
  end
end
```

---

# Code Break

---

# Wrap up

---

Prefer

```ruby
create(:admin)
```

To

```ruby
create(:user, admin: true)
```

---

Prefer

```ruby
create(:user, :with_github_identity)
```

To

```ruby
create(:user, github_username: "githubuser", github_token: "123")
```

---

Prefer

```ruby
expect_to_be_signed_in
```

To

```ruby
expect(page).to have_text "Signed in"
```

---

Prefer

```ruby
expect(page).to have_active_subscription
```

To

```ruby
expect(page).to have_css(".active")
```

---

Prefer

```ruby
cancel_payment_page = CancelPaymentPage.new

cancel_payment_page.cancel_charge(charge)

expect(cancel_payment_page).to have_canceled_charge(charge)
```

To

```ruby
within "#charge-#{charge.id}" do
  click_on t("charges.index.cancel")

  expect(page).to have_text(t("charges.index.canceled_charge"))
end

```

---

Prefer

```ruby
form = PaymentForm.new
form.fill_in_with_invalid_credit_card
form.submit

expect(form).to have_error_on_credit_card_field
```

To

```ruby
fill_in "Card Number", with: "invalid credit card number"
select "10", from: "date[month]"
select "2020", from: "date[year]"
fill_in "CVC", with: "333"
click_button "Submit Payment"

expect(page).to have_css?("#payment_credit_card .error")
```

---

Prefer

```ruby
expect(test).to reveal_intent
```

To

```ruby
expect(test).to reveal_implementation
```

---

# Thanks!

  * Slides: [github.com/bernerdschaefer/talks][talks]
  * Follow me: [@bjschaefer](https://twitter.com/bjschaefer)
  * Email me: [b@thoughtbot.com](mailto:b@thoughtbot.com)
  * Hire me: [https://thoughtbot.com/](https://thoughtbot.com/)

  [talks]: https://github.com/bernerdschaefer/talks
