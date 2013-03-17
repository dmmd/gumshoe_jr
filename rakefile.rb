require 'rsolr'
require 'yaml'
require 'java'
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
  end
  namespace :solrizer do
    desc "Add files to index"
    task :add_single do
      Dir["#{settings['classpath']}\*.jar"].each { |jar| require jar }
      file = ENV['FILE']
      index = ENV['INDEX']
      org.nypl.mss.erecs.JRubyInterface.new(file, index, settings['solr'])  
    end
  end
end