class PlayWorker
  include Sidekiq::Worker

  def perform(*args)
    # Pass in api key to client
    at_client = Airtable::Client.new('keyTycbrAXKjR7VPu')
    at_test   = at_client.table('appPJ6HUieDnNWxOi', 'Test')
    record    = Airtable::Record.new('Name' => 'Thing1')
    at_test.create(record)
  end
end
