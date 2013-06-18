require 'digest/sha1'
module Sec
  def generate_admin(password)
    user = "admin"
    salt = Time.now.to_s
    prehash = salt + password
    hash = Digest::SHA1.hexdigest prehash
    user << "|" << salt << "|" << hash << "|admin"
  end
  def generate_user(login, password)
    salt = Time.now.to_s
    prehash = salt + password
    hash = Digest::SHA1.hexdigest prehash
    login << "|" << salt << "|" << hash << "|user"
  end
end

