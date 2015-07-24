class String
  def reverse_color;  "\033[7m#{self}\033[27m" end
  def bold;           "\033[1m#{self}\033[22m" end
  def black;          "\033[30m#{self}\033[0m" end
  def green;          "\033[32m#{self}\033[0m" end
  def bg_red;         "\033[41m#{self}\033[0m" end
end