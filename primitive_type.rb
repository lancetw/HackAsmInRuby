# Convert to binary string
class Integer
  def to_bin(width)
    '%0*b' % [width, self]
  end
end

# Check a string is numveric or not
class String
  def numeric?
    !Float(self).nil? rescue false
  end
end
