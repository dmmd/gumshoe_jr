require 'rsolr-ext'
require 'yaml'
require 'rake'

settings = YAML.load(File.open("conf/eri.yml"))

namespace :eri do
  solr = RSolr.connect :url => settings['solr']
  namespace :index do
    desc "Optimize Solr index"
    task :optimize do
      response = solr.optimize
        if response['responseHeader']['status'] == 0 then
          puts "index optimized"
        else
          puts "error: " << response
        end
    end
  
    desc "Delete all records from index"
    task :nuke do
      response = solr.delete_by_query '*:*'
        if response['responseHeader']['status'] == 0 then
          solr.commit
          solr.optimize
          puts "all records in index deleted"
        else
          puts "error: " << response
        end
    end
  
    desc "Returns the count of records in the index"
    
    task :get_count do
      response = solr.get('select', :params => {:q=>'id:*'})
        if response['responseHeader']['status'] == 0 then
          puts response['response']['numFound'].to_s << " records in index"
        else
          puts "error: " << response
        end
    end
    
    desc "Delete a single record in the index on id"
    task :del_record do
      solr.delete_by_query("id:" + ENV['ID'])
      solr.commit
      solr.optimize
    end
    
    desc "Run a query"
    task :query do
      response = solr.get('select',
        :params => {:q => ENV['Q']}
      )
      puts response
    end
      
      
    
    desc "Delete all records in the index for a collection"
    task :del_col do
      col = "cid: " + ENV['COL']
      
      solr_params =  {
        :queries => "cid:*",
        :facets =>{:fields => ["cid"]}
      }
      
      response = solr.find(solr_params, :method => :post)
      cArray = response['facet_counts']['facet_fields']['cid']
      hash = Hash[cArray.map.with_index.to_a]
      index = hash[ENV['COL']].to_i + 1
      puts "deleting " + cArray[index].to_s + " records from index"
      puts "proceed - 'yes'"
      r = STDIN.gets.chomp
      
      if r == "yes" then
        solr.delete_by_query col
        solr.commit
        solr.optimize
        puts "All records from " + ENV['COL'] + "deleted from index"
      else
        puts "Cancelling deletion"
      end
    end 
  end
end