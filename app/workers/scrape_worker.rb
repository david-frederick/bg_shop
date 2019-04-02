class ScrapeWorker
  include Sidekiq::Worker
  sidekiq_options queue: :scraping, backtrace: true

  def perform(endpoint_id)
    endpoint = Endpoint.find(endpoint_id)
    return if endpoint.scraped?

    case endpoint.url
    when /https:\/\/www.reddit.com\/r\/boardgames.*/
      RedditScraper.scrape(endpoint)
    else
      # TODO
    end
  end
end
