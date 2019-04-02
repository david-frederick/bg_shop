class RedditScraper
  def self.scrape(endpoint)
    # contents = Net::HTTP.get(URI.parse(endpoint.url))

    client = OAuth2::Client.new(ENV['REDDIT_API_KEY'], ENV['REDDIT_API_SECRET'], site: 'https://www.reddit.com/api/v1/authorize')
    # response_type=TYPE&state=RANDOM_STRING&redirect_uri=URI&duration=DURATION&scope=SCOPE_STRING

    client.auth_code.authorize_url(redirect_uri: 'http://localhost:8080/oauth2/callback')
    # => "https://example.org/oauth/authorization?response_type=code&client_id=client_id&redirect_uri=http://localhost:8080/oauth2/callback"

    token = client.auth_code.get_token('authorization_code_value', :redirect_uri => 'http://localhost:8080/oauth2/callback', :headers => {'Authorization' => 'Basic some_password'})
    response = token.get('/api/resource', :params => { 'query_foo' => 'bar' })
    response.class.name

    puts "-------- CONTENTS --------"
    puts contents
    puts "-------- END --------"
    return
  end
end
