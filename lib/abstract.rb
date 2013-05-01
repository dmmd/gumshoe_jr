require 'nokogiri'
module Abstract
  def get_abstract(id)
    f = File.open("desc/abstracts.xml")
    doc = Nokogiri::XML(f)
    f.close
    doc.xpath("//archivalAbstract[@id=\'#{id}\']/colAbstract").text
  end
end