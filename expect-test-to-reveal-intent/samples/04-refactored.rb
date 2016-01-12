click_on "Add article"
expect_article_to_be_removable

def expect_article_to_be_removable
  expect(page).not_to have_css(
    ".tooltip_list-link_add", text: article.name
  )
  expect(page).to have_css(
    ".tooltip_list-link_remove", text: article.name
  )
end
