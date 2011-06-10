class String
  def indent(spaces)
    gsub(/^/, " " * spaces)
  end
  
  # returns last non-empty line of string, or the empty string if none exists
  def last_line
    lines = split("\n")
    while line = lines.pop
      line.strip!
      return line unless line.length == 0
    end
    return ''
  end
end