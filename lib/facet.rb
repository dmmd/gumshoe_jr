module Facet
  require 'rsolr-ext'
  require 'sinatra/config_file'
  
  config_file './conf/eri.yml'
  
  @solr = RSolr.connect :url => settings.solr
  
  def get_collection_nums()
    solr_params =  {
      :queries => "colId:*",
      :fl => "colId",
      :facets => {:fields => ["colId"]}
    }

    response = @solr.find(solr_params, :method => :post)

    cols = Set.new
    count = 0
    response["facet_counts"]['facet_fields']['colId'].each do |col|
      if count % 2 == 0
        cols.add col
      end
      count += 1
    end
    cols
  end
  
  def get_collection_name(col)
    solr_params =  {
      :queries => "colId:" + col,
      :rows => 1,
      :start => 1,
      :fl => "colName"
    }
    @solr.find(solr_params, :method => :post)['response']['docs'][0]['colName']
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
