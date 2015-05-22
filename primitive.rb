class Integer
  def to_bin(width)
    '%0*b' % [width, self]
  end
end

class String
  def numeric?
    Float(self) != nil rescue false
  end
end
