module EriLog
  def log_search(user, qType, q)
    string = Time.now.to_i.to_s + "\t QUERY\t" + user + "\t" + qType + "\t" + q + "\n"
    File.open('log/queries.log','a') do|f|
      f.write(string)
      f.close
    end
  end
  
  def log_file(user, file)
    string = Time.now.to_i.to_s + "\t FILE\t" + user + "\t" + file + "\n"
    File.open('log/queries.log','a') do|f|
      f.write(string)
      f.close
    end
  end
end