class AirtableSyncWorker
  include Sidekiq::Worker

  def perform(*args)
    @at_client  = Airtable::Client.new('keyTycbrAXKjR7VPu')
    @flgs_table = @at_client.table('appPJ6HUieDnNWxOi', 'FLGS')
    sync_records
  end

  def sync_records(offset = nil)
    flgs_list = @flgs_table.records(offset: offset)

    flgs_list.each do |flgs|
      shop = Shop.find(flgs.pgid)
      shop.name     = flgs[:name]
      shop.url      = flgs[:url]
      shop.phone    = flgs[:phone]
      shop.country  = flgs[:country]
      shop.region   = flgs[:region]
      shop.city     = flgs[:city]
      shop.raw_data = flgs[:data]
      shop.raw_followup = flgs[:followup]
      shop.has_cart = flgs[:cart]
      shop.has_site = flgs[:site]
      shop.save!
    end

    sync_records(flgs_list.offset) unless flgs_list.offset.blank?
  end
end
