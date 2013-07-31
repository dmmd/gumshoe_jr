require 'rsolr-ext'

module Entities
  def getHash(solr, comp, type)
    response = solr.get 'select', :params => {
      :q =>"parentId:" + comp,
      :fq => "type:" + type,
      :fl => "entity, count",
      :start=>0,
      :rows=>20000
    }

    orgs = Hash.new
    response['response']['docs'].each do |doc|
      orgs[doc['entity']] = doc['count']
    end

    orgs
  end
end



