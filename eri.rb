require 'sinatra'
require 'sinatra/config_file'
require 'haml'
require 'rsolr'
require 'trinidad'
require 'lib/time.rb'
require 'lib/login.rb'
require 'lib/log.rb'
require 'sinatra/flash'

include TimeModule
include EriAuth
include EriLog

v = "Electronic Records Index [0.2.0a]"

enable :sessions

use Rack::Session::Cookie, :key => 'rack.session',
                           :path => '/',
                           :expire_after => 12000, # In seconds
                           :secret => 'd32908e75160962571c7ef3ea6b4865755a2ae6b'
                           
configure do
  set :server, :trinidad
end

config_file './conf/eri.yml'
solr = RSolr.connect :url => settings.solr

def get_or_post(path, opts={}, &block)
  get(path, opts, &block)
  post(path, opts, &block)
end

get '/' do
  if(session['login'] != true)
    redirect "/login"
  end
  
  @version = v
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

get "/login" do
  @version = v
  @page = "Login to ERI"
  haml :login
end

#administrative functions
get "/logout" do
  session["login"] = nil
  session["user"] = nil
  flash[:notice] = "You have been logged out"
  redirect "/"
end

post '/authenticate' do
  login = params[:name]
  password = params[:password]
  puts params
  result = EriAuth.test_login(login, password)
  puts "RESULT " << result.to_s
  if result == true then 
    session["login"] = true
    session["user"] = login
    puts "user logged in " +  session["user"]
    redirect "/"
  else
    flash[:error] = "Login failed"
    redirect "/login"
  end
end

#controllers w/views
get_or_post '/results' do
  
  if(session['login'] != true)
    redirect "/login"
  end
  
  @page = "Search Results" 
  @q = params[:query]
  @qt = params[:qType]
  @start = params[:start].to_i
  @version = v
  
  EriLog.log_search(session['user'], @qt, @q) 
  
  if @qt == "full text" then
    @query = @q
  else
    @query = ""
    @query << @qt
    @query << ":" << @q
  end

  response = solr.get 'select', :params => {
    :q => @query,
    :start=> @start,
    :rows=>20
  }
  
  @result = response
  @fields = {"collection" => "cName", "component" => "series", "disk id" => "did", "file type" => "fType", "size" => "fSize", 
    "original filename" => "accessfilename", "mod date" => "mDate", "language" => "language"} 
  
  @links = {"collection" => "cid", "component" => "component", "disk" => "did"}
  @tm = TimeModule
  haml :results
  
end

get '/component' do
  
  if(session['login'] != true)
    redirect "/login"
  end
  
  @component = params[:component]
  @page = "Component Display" 
  response = solr.get 'select', :params => {
    :q=>"series:" << @component,
    :start=>0,
    :rows=>2000
  }
  @result = response
  @version = v
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
  
  haml :component
end

get '/disk' do
  
  if(session['login'] != true)
    redirect "/login"
  end
  
  @page = "Media Display" 
  @did = params[:did]
  @cname = params[:cname]
  @version = v
  
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
  
  if(session['login'] != true)
    redirect "/login"
  end
  
  @version = v
  @page = "Collection Display" 
  @cid = params[:cid]

  response = solr.get 'select', :params => {
    :q=>"cid:" << @cid,
    :start=>0,
    :rows=>2000,
    :fl => "series, parentseries, cName, did"
  }

  @components = SortedSet.new
  @media = SortedSet.new
  @cname
  response['response']['docs'].each do |doc|
    @components.add doc['series']
    @media.add doc['did']
    @cname = doc['cName']
  end
  
  haml :collection
end

get '/file' do
  
  if(session['login'] != true)
    redirect "/login"
  end
  
  @page = "File Display" 
  @id = params[:id]
  @fields = {"id" => "id", "filename" => "filename", "file type" => "fType", "size" => "fSize", "original filename" => "accessfilename", "last modification date" => "mDate", "language" => "language", "collection" => "cName", "series" => "series", "disk" => "did", "path" => "path"}
  @links = {"collection" => "cid", "series" => "series", "disk" => "did"}
  @version = v
  response = solr.get 'select', :params => {
    :q=>"id:" << @id,
    :start=>0,
    :rows=>50
  }
  
  EriLog.log_file(session['user'], @id) 
  @version = v
  @result = response
  @tm = TimeModule
  haml :file
end

get '/path' do
  
  if(session['login'] != true)
    redirect "/login"
  end
  
  @version = v
  @page = "Path Display" 
  @path = params["path"]
  haml :path
end

get '/about' do
  
  if(session['login'] != true)
    redirect "/login"
  end
  @version = v
  @page = "About"
  haml :about
end 
