require 'digest/sha1'

module EriAuth
  def test_login(login, password)
    line = find_line(login)
    if(line != nil) then
      salt = line.split("|")[1].strip
      test = line.split("|")[2].strip
      hash = Digest::SHA1.hexdigest salt + password
      hash.eql? test
    else
      false
    end
  end
  
  def test_admin(login, password)
    line = find_line(login)
    puts "admin: " + line.split("|")[3]
    if line.split("|")[3].strip == "admin" then
      true
    else
      false
    end 
  end

  def find_line(login)
    result = nil
    f = File.open('access.txt')
    f.each do |line|
      if login == line.split("|")[0]
        result = line
        break
      end
    end
    f.close
    return result
  end
end