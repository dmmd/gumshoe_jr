module Facet
  require 'rsolr-ext'
  
  
  @solr = RSolr.connect :url => "http://localhost:8983/solr"
  
  def get_collection_nums()
    solr_params =  {
      :queries => "cid:*",
      :fl => "cid",
      :facets => {:fields => ["cid"]}
    }

    response = @solr.find(solr_params, :method => :post)

    cols = Set.new
    count = 0
    response["facet_counts"]['facet_fields']['cid'].each do |col|
      if count % 2 == 0
        cols.add col
      end
      count += 1
    end
    cols
  end
  
  def get_collection_name(col)
    solr_params =  {
      :queries => "cid:" + col,
      :rows => 1,
      :start => 1,
      :fl => "cName"
    }
    @solr.find(solr_params, :method => :post)['response']['docs'][0]['cName']
  end
  
  def get_collection_hash()
    cols = Hash.new
    get_collection_nums.each do |col|
      name = get_collection_name(col)
      cols[col] = name
    end
    return cols
  end
end
