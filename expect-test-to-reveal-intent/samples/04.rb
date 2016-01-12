click_on "Add article"
expect(page).not_to have_css("a.add-article")
expect(page).to have_css("a.remove-article")
