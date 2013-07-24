require 'rsolr-ext'
require 'yaml'
require 'rake'
require './lib/sec.rb'
require './lib/login.rb'

settings = YAML.load(File.open("conf/eri.yml"))

namespace :eri do
  solr = RSolr.connect :url => settings['solr']
  
  task :init do

    include Sec
    puts "initializing application"
    log = "log/events.log"
    #create the event log
    if(File.exist? log) then
      puts "log exists"
    else
      puts "creating event log"
      File.new(log, "w")
      if(File.exist? log) then
        puts "event log creation successful"
      else
        puts "event log not created"
        if(File.exist? log) then
          puts "log exists"
        else
          puts "creating event log"
        end
      end
    end
      
    #create the access file
    access_file = "access.txt"
    if File.exist? access_file then
      puts "access file exists"
    else
      puts "creating access file"
      puts "enter a password for the admin account"
      pass = STDIN.gets.chomp
      line = Sec.generate_admin(pass)
      File.new(access_file, "w")
      File.open(access_file, 'a') do |f|
        f.puts(line)
      end
    end
    
  end
  
  namespace :login do
    include EriAuth
    task :authenticate do
      puts "enter username"
      login = STDIN.gets.chomp
      puts "enter password"
      password = STDIN.gets.chomp
      if EriAuth.test_login(login, password) then
        puts "credentials are valid"
      else
        puts "credentials are not valid"
      end
    end
    task :add_user do
      include Sec
      puts "enter username"
      login = STDIN.gets.chomp
      puts "enter password"
      password = STDIN.gets.chomp
      line = Sec.generate_user(login, password)
      File.open("access.txt", 'a') do |f|
        f.puts(line)
      end
    end
  end
  
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
    
    desc "Delete all records from a compent"
    task :del_comp do
      solr.delete_by_query("componentIdentifier:" + ENV['COMP'])
      solr.commit
      solr.optimize
      puts "complete"
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
    
    desc "Deleta a fileType"
    task :del_type do
      solr.delete_by_query("fileType:" + ENV['TYPE'])
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
      solr.delete_by_query("colId:" + ENV['COL'])
      solr.commit
      solr.optimize
    end 
  end
end