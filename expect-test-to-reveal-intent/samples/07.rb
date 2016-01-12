scenario "User loads more articles" do
  user = create(:user)
  create(:article, headline: "first")
  create(:article, headline: "second")

  login_as user
  visit articles_path

  expect(all(".headline").map(&:text)).to eq([
    "first",
  ])

  click_on "Load more"

  expect(all(".headline").map(&:text)).to eq([
    "first",
    "second",
  ])
  expect(page).not_to have_text "Load more"
end
