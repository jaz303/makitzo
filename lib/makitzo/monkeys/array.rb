class Array
  def in_groups_of(group_size)
    out = []
    each_with_index do |ele, i|
      out << [] if i % group_size == 0
      out.last << ele
    end
    out
  end
end