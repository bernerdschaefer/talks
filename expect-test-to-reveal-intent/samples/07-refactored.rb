scenario "User loads more articles" do
  user = create(:user)
  create(:article, headline: "first")
  create(:article, headline: "second")

  login_as user
  visit articles_path
  articles_page = ArticlesPage.new


  expect(articles_page).to have_heaadlines(["first"])

  articles_page.load_more

  expect(articles_page).to have_headlines(["first", "second"])

  expect(articles_page).not_to have_more
end

class ArticlesPage
  def has_headlines?(headlines)
    headlines_on_page == headlines
  end

  def has_more?
    has_text? "Load more"
  end

  def load_more
    click_on "Load more"
  end

  private

  def headlines_on_page
    alld(".headline").map(&:text)
  end
end
