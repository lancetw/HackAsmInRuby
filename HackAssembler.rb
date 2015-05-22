require_relative('primitive_type')
require_relative('lookup_table')

# HackAsm to BinaryString Hack file Assembler
class HackAssembler
  def initialize
    @foo = []
    @bar = []
    @baz = {}
  end

  def read(line)
    @foo << line
  end

  def to_s
    "#{@bar}"
  end

  def parse
    @bar = Marshal.load(Marshal.dump(@foo)) # deep clone
    pre_clean
    parse_symbols
    prepare_addrs
    trans_a_instruct
    trans_c_instruct
    @bar
  end

  def trans_a_instruct
    @bar.map! do |line|
      line =
        if line[0] == '@'
          line.slice!(0)
          line[0] == 'R' && line.slice!(0)
          (TABLE_P.include? line) ? TABLE_P[line] : line.to_i
        else
          line
        end
    end
  end

  def trans_c_instruct
    @bar.map! do |line|
      unless line.is_a? Numeric
        s, jmp = line.split(/\;/)
        line = TABLE_J[jmp]
        s.include?('=') ? (dst, cmp = s.split(/\=/)) : (cmp = s)
        dst = TABLE_D[dst]
        line += (dst << 3) unless dst.nil?
        (TABLE_C_A0.include? cmp) ? (cmp = TABLE_C_A0[cmp]) : (cmp = TABLE_C_A1[cmp]; line += 0x1000)
        line = ((cmp.nil?) ? line : (line + (cmp << 6))) + 0xE000
      end
      line = line.to_bin(16)
    end
  end

  def parse_symbols
    h = {}
    i = 0
    @bar.each do |line|
      key = line.scan(/\(([^"]*)\)/).join
      if key.empty?
        i += 1
        next
      end
      h[key] = i
    end
    @baz = h

    a = []
    @bar.each do |line|
      key = line.scan(/\(([^"]*)\)/).join
      a << line if key.empty?
    end
    @bar = a
  end

  def prepare_addrs
    addr = 0x10
    @bar.map! do |line|
      key = line.scan(/\@([^"]*)/).join
      s = (!key.empty?) ? @baz[key] : line
      line =
        if s.nil?
          unless (TABLE_P.key? key) || key.numeric? || key[0] == 'R'
            TABLE_P[key] = addr
            addr += 1
          end
          line
        else
          s
        end
    end
  end

  def pre_clean
    a = []
    @bar.each do |line|
      line.sub!(%r{//.*}, '')
      line.strip!
      a << line unless line.empty?
    end
    @bar = a
  end

  private :pre_clean,
          :parse_symbols,
          :prepare_addrs,
          :trans_a_instruct,
          :trans_c_instruct
end
