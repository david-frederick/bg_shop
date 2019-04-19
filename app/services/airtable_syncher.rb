class AirtableSyncher
  def initialize
    @at_client  = Airtable::Client.new('keyTycbrAXKjR7VPu')
    @flgs_table = @at_client.table('appPJ6HUieDnNWxOi', 'FLGS')
  end

  def write_flgs(**params)
    record = Airtable::Record.new(
      'Name'     => params[:name],
      'URL'      => params[:url],
      'Data'     => params[:data],
      'Followup' => params[:followup].try('join', '\n'),
      'Phone'    => params[:phone],
      'Country'  => params[:country][:name],
      'Region'   => params[:region][:name] == :default ? '' : params[:region][:name],
      'City'     => params[:city][:name] == :default ? '' : params[:city][:name],
      'Cart'     => params[:has_cart],
      'Site'     => params[:has_site],
      'PGID'     => params[:pg_id],
      'BadUrl'   => params[:bad_url]
    )

    ap record

    ap @flgs_table.create(record)
  end

  def sync_records(offset = nil)
    flgs_list = @flgs_table.records(offset: offset)

    flgs_list.each do |flgs|
      shop = Shop.find(flgs.pgid)
      shop.name         = flgs[:name]
      shop.url          = flgs[:url]
      shop.phone        = flgs[:phone]
      shop.country      = flgs[:country]
      shop.region       = flgs[:region]
      shop.city         = flgs[:city]
      shop.raw_data     = flgs[:data]
      shop.raw_followup = flgs[:followup]
      shop.has_cart     = flgs[:cart]
      shop.has_site     = flgs[:site]
      shop.save!
    end

    sync_records(flgs_list.offset) unless flgs_list.offset.blank?
  end

  def ta_records
    flgs_list = @flgs_table.select(formula: "TA = 1")

    flgs_list.each do |flgs|
      shop = Shop.new
      shop.name         = flgs[:name]
      shop.url          = flgs[:url]
      shop.phone        = flgs[:phone]
      shop.country      = flgs[:country]
      shop.region       = flgs[:region]
      shop.city         = flgs[:city]
      shop.raw_data     = flgs[:data]
      shop.raw_followup = flgs[:followup]
      shop.has_cart     = flgs[:cart]
      shop.has_site     = flgs[:site]
      shop.save!
    end
  end
end
