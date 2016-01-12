scenario "loads articles in order" do
  user = create(:user)
  create(:article, headline: "first")
  create(:article, headline: "second")

  login_as user
  visit articles_path

  articles_page = ArticlesPage.new

  expect(articles_page.extract_headlines).to eq([
    "first",
  ])

  article_page.load_more

  expect(articles_page.extract_headlines).to eq([
    "first",
    "second",
  ])

  expect(article_page).to be_completely_loaded
end

class ArticlesPage
  def extract_headlines
    all(".headline").map(&:text)
  end

  def load_more
    click_on "Load more"
  end

  def is_completely_loaded?
    !has_text?("Load more")
  end
end
