feature "User views articles" do
  scenario "and loads more" do
    user = create(:user)
    create_list(:article, 2)

    login_as user
    visit articles_path

    articles_page = ArticlesPage.new

    expect(articles_page).to have_article_count(1)

    article_page.load_more

    expect(articles_page).to have_article_count(2)
    expect(article_page).to be_completely_loaded
  end
end

class ArticlesPage
  def extract_headlines
    all(".headline").map(&:text)
  end

  def has_article_count?(count)
    has_css?(".article", count: count)
  end

  def load_more
    click_on "Load more"
  end

  def is_completely_loaded?
    !has_text?("Load more")
  end
end
