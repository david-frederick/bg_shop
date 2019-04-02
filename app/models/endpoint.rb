class Endpoint < ApplicationRecord
  validates :url, uniqueness: true
  enum status: [:enqueued, :scraped]
end
