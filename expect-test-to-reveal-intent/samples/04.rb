click_on "Add article"
expect(page).not_to have_css(
  ".add_article", text: article.name
)
expect(page).to have_css(
  ".remove_article", text: article.name
)
