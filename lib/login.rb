require 'digest/sha1'

module EriAuth
  def test_login(login, password)
    line = find_line(login)
    if(line != nil) then
      salt = line.split("|")[1].strip
      test = line.split("|")[2].strip
      hash = Digest::SHA1.hexdigest salt + password
      puts test
      puts hash
      hash.eql? test
    else
      false
    end
  end

  def find_line(login)
    File.open('access.txt').each do |line|
      if login == line.split("|")[0]
        return line
        break
      end
    end
    return nil
  end
end