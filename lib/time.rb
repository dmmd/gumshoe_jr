module TimeModule
  def get_name
    "Donald Mennerich 2"
  end
  
  def convert_time(timeIn)
    if timeIn == nil
      nil
    else
      timeIn.split("T")[0].split("-")[1] << "/" << timeIn.split("T")[0].split("-")[2] << "/" << timeIn.split("T")[0].split("-")[0]
    end
  end
  
  def convert_bytes(bytes)
    if bytes == nil
      nil
    else
      b = Float(bytes)
      if b < 1024
        bytes << " bytes"
      elsif b > 1024
        (b / 1024).round(2).to_s << " kb"
      end
    end
  end
end