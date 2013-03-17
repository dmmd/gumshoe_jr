require 'sinatra'
require 'sinatra/config_file'
require 'puma'
require 'haml'
require 'rsolr'
require 'trinidad'

configure do
  set :server, :trinidad
end

config_file './conf/eri.yml'
solr = RSolr.connect :url => settings.solr

use Rack::Auth::Basic, "ERI Restricted" do |username, password|
  [username, password] == [settings.user, settings.password]
end

def get_or_post(path, opts={}, &block)
  get(path, opts, &block)
  post(path, opts, &block)
end

get '/' do 
  @page = "Electronic Records Index" 
  response = solr.get 'select', :params => {
    :q=>params["id:*"],
    :start=>0,
    :rows=>2000
  }
  
  @cols = Hash.new
  response['response']['docs'].each do |doc|
    puts "hello"
  end
  
  haml :index
end

get_or_post '/results' do
  @page = "Search Results" 
  @q = params[:query]
  @qt = params[:qType]

  if @qt == "full text" then
    @query = @q
  else
    @query = @qt << ":" << @q
  end

  response = solr.get 'select', :params => {
    :q => @query,
    :start=>0,
    :rows=>50
  }
  
  @result = response
  @fields = {"id" => "id", "filename" => "filename", "file type" => "fType", "size" => "fSize", 
    "original filename" => "accessfilename", "lmod date" => "mDate", "language" => "language", "collection" => "cName", 
    "series" => "series", "disk" => "did", "path" => "path"}
  @links = {"collection" => "cid", "series" => "series", "disk" => "did", "filename" => "id"}
  haml :results
  
end

get '/series' do
  @series = params[:series]
  @page = "Archival File Display" 
  response = solr.get 'select', :params => {
    :q=>"series:" << @series,
    :start=>0,
    :rows=>2000
  }
  @result = response
  
  @names = Hash.new
  @orgs = Hash.new
  @locs = Hash.new
  response['response']['docs'].each do |doc|
  	
  	if doc['names'] then
    	doc['names'].each do |name|
    	  name = name.tr("'", "")
    	  name = name.tr('"', '')
        if @names.has_key? name then
          @names[name] = @names[name] + 1
        else
          @names[name] = 1
        end
    	end
    end
  	
  	if doc['orgs'] then
    	doc['orgs'].each do |org|
    	  org = org.tr("'", "")
    	  org = org.tr('"', '')
        if @orgs.has_key? org then
          @orgs[org] = @orgs[org] + 1
        else
          @orgs[org] = 1
        end
    	end
    end
    
    if doc['locs'] then
      doc['locs'].each do |loc|
    	  loc = loc.tr("'", "")
    	  loc = loc.tr('"', '')
        if @locs.has_key? loc then
          @locs[loc] = @locs[loc] + 1
        else
          @locs[loc] = 1
        end
    	end
  	end
  end
  
  haml :series
end

get '/disk' do
  @page = "Media Display" 
  @did = params[:did]
  @cname = params[:cname]

  response = solr.get 'select', :params => {
    :q=>"did:" << @did,
    :start=>0,
    :rows=>2000
  }
  
  
  @names = Hash.new
  @orgs = Hash.new
  @locs = Hash.new
  response['response']['docs'].each do |doc|
  	
  	if doc['names'] then
    	doc['names'].each do |name|
    	  name = name.tr("'", "")
    	  name = name.tr('"', '')
        if @names.has_key? name then
          @names[name] = @names[name] + 1
        else
          @names[name] = 1
        end
    	end
    end
  	
  	if doc['orgs'] then
    	doc['orgs'].each do |org|
    	  org = org.tr("'", "")
    	  org = org.tr('"', '')
        if @orgs.has_key? org then
          @orgs[org] = @orgs[org] + 1
        else
          @orgs[org] = 1
        end
    	end
    end
    
    if doc['locs'] then
      doc['locs'].each do |loc|
    	  loc = loc.tr("'", "")
    	  loc = loc.tr('"', '')
        if @locs.has_key? loc then
          @locs[loc] = @locs[loc] + 1
        else
          @locs[loc] = 1
        end
    	end
  	end
  end

  @result = response
  haml :disk
end

get '/collection' do
  @page = "Collection Display" 
  @cid = params[:cid]

  response = solr.get 'select', :params => {
    :q=>"cid:" << @cid,
    :start=>0,
    :rows=>2000,
    :fl => "series, parentseries, cName, did"
  }

  @series = SortedSet.new
  @media = SortedSet.new
  @cname
  response['response']['docs'].each do |doc|
    @series.add doc['series']
    @media.add doc['did']
    @cname = doc['cName']
  end
  
  haml :collection
end

get '/file' do
  @page = "File Display" 
  @id = params[:id]
  @fields = {"id" => "id", "filename" => "filename", "file type" => "fType", "size" => "fSize", "original filename" => "accessfilename", "last modification date" => "mDate", "language" => "language", "collection" => "cName", "series" => "series", "disk" => "did", "path" => "path"}
  @links = {"collection" => "cid", "series" => "series", "disk" => "did"}

  response = solr.get 'select', :params => {
    :q=>"id:" << @id,
    :start=>0,
    :rows=>50
  }

  @result = response
  haml :file
end

get '/path' do
  @page = "Path Display" 
  @path = params["path"]
  haml :path
end
