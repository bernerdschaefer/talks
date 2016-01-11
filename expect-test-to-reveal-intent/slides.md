class: center, middle

# expect(test).to reveal_intent

.footnote[Bernerd Schaefer / Developer @ thoughtbot]

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

# Factory Girl

---

# Factory Girl

```ruby
subscription = create(:subscription, active: true)
create(
  :user,
  github_username: "githubuser",
  github_token: "123",
  subscription: subscription,
)
```

---

# Convey state or type with nested factories

---

# Convey state or type with nested factories

```ruby
subscription = create(:subscription)
create(:user, subscription: subscription)
```

---

# Convey state or type with nested factories

```ruby
factory :user do
  factory :subscriber do
    subscription
  end
end

create(:subscriber)
```

---

# Group attributes with traits

---

# Group attributes with traits

```ruby
create(
  :user,
  github_username: "githubuser",
  github_token: "123",
)
```

---

# Group attributes with traits

```ruby
factory :user do
  trait :with_github_identity do
    github_username "githubuser"
    github_token "123"
  end
end

create(:user, :with_github_identity)
```

---

# Let's refactor

---

# Let's refactor

```ruby
create(:user, admin: true)
```

---

# Let's refactor

```ruby
factory :user do
  factory :admin do
    admin true
  end
end

create(:admin)
```

---

# Let's refactor

```ruby
create(:job, starts_on: 1.year.ago, ends_on: 2.months.ago)
create(:job, starts_on: 1.month.ago, ends_on: nil)
```

---

# Let's refactor

```ruby
create(:job, :current)
create(:job, :previous)

factory :job do
  trait :previous do
    starts_on { 1.year ago }
    ends_on { 2.months.ago }
  end

  trait :current do
    starts_on { 1.month.ago }
    ends_on nil
  end
end
```

---

# RSpec and Capybara

---

# Extract actions

---

# Extract actions

```ruby
fill_in "Email", with: user.email
fill_in "Password", with: "test"
click_on "Sign In"
```

---

# Extract actions

```ruby
sign_in_as(user)

def sign_in_as(user)
  fill_in "Email", with: user.email
  fill_in "Password", with: "test"
  click_on "Sign In"
end
```

---

# Extract matchers

---

# Extract matchers

```ruby
expect(page).to have_css(".jobs .current", text: job.title)
```

---

# Extract matchers

```ruby
expect(page).to have_current_job(job)

def have_current_job(job)
  expect(page).to have_css(".jobs .current", text: job.title)
end
```

---

# Extract expectations

---

# Extract expectations

```ruby
ordered_job_titles = Job.order(starts_on: :desc).map(&:title)
job_titles = all(".job .title").map(&:text)
expect(job_titles).to eq(ordered_job_titles)
```

---

# Extract expectations

```ruby
expect_jobs_in_reverse_chronological_order

def expect_jobs_in_reverse_chronological_order
  ordered_job_titles = Job.order(starts_on: :desc).map(&:title)
  job_titles = all(".job .title").map(&:text)
  expect(job_titles).to eq(ordered_job_titles)
end
```

---

# Let's refactor

---

# Let's refactor

```ruby
expect(page).to have_css(".job.current")
```

---

# Let's refactor

```ruby
click_on "Add article"
expect(page).not_to have_css(
  ".tooltip_list-link_add", text: article.name
)
expect(page).to have_css(
  ".tooltip_list-link_remove", text: article.name
)
```

---

# Extract page objects

---

# Page objects wrap part or all of a page with a user-focused API

---

# Extract page objects

```ruby
within "#charge-#{charge.id}" do
  expect(page).to have_text("Pending")

  click_on "Cancel"

  expect(page).to have_text("Canceled"))
end
```

---

# Extract page objects

```ruby
payment_page = PaymentPage.new

expect(payment_page).to have_pending_charge(charge)
payment_page.cancel_charge(charge)
expect(payment_page).to have_canceled_charge(charge)
```

---

# Extract page objects

```ruby
class PaymentPage
  include Capybara::DSL

  def cancel_charge(charge)
    within_charge(charge) do
      click_on "Cancel"
    end
  end

  def has_pending_charge?(charge)
    within_charge(charge) do
      expect(page).to have_text("Pending")
    end
  end

  def has_canceled_charge?(charge)
    within_charge(charge) do
      expect(page).to have_text("Canceled")
    end
  end
end
```

---

# Let's refactor

```ruby
visit my_account_path
click_link "Cancel subscription"
fill_in "cancellation_reason", with: "I didn't like it"
click_button "Confirm subscription cancelation"
expect(page).to have_text "Subscription canceled"
```

---

# Wrap up

---

# Nested factories

Prefer

```ruby
create(:subscriber)
```

To

```ruby
subscription = create(:subscription)
create(:user, subscription: subscription)
```

---

# Traits

Prefer

```ruby
create(:user, :with_github_identity)
```

To

```ruby
create(:user, github_username: "githubuser", github_token: "123")
```

---

# Actions

Prefer

```ruby
sign_in_as(user)
```

To

```ruby
fill_in "Email", with: user.email
fill_in "Password", with: "test"
click_on "Sign In"
```

---

# Expectations

Prefer

```ruby
expect_to_be_signed_in
```

To

```ruby
expect(page).to have_text "Signed in"
```

---

# Matchers

Prefer

```ruby
expect(page).to have_active_subscription
```

To

```ruby
expect(page).to have_css(".active")
```

---

# Page objects

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

# Always

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
