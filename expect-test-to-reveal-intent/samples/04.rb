click_on "Add article"
expect_article_to_be_removable

def ensure_single_article
  expect(page).not_to have_css("a.add-article")
  expect(page).to have_css("a.remove-article")
end
