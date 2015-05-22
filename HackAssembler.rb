require_relative('primitive')
require_relative('lookupTable')

class HackAssembler

  def initialize
    @foo = Array.new
    @bar = Array.new
    @baz = Hash.new
  end

  def read(line)
    @foo << line
  end

  def parse
    @bar = Marshal.load(Marshal.dump(@foo)) # deep clone
    pre_clean; parse_symbols
    prepare_addrs
    run_A_instruct
    run_C_instruct

    return self.out
  end

  def run_A_instruct
    @bar.map! do |line|
      if line[0] == '@' then line[0] = ''
        if line[0] == 'R' then line[0] = '' end
        line = (TABLE_P.include? line) ? TABLE_P[line] : line.to_i
      else line = line end
    end
  end

  def run_C_instruct
    @bar.map! do |line|
      if not line.is_a? Numeric
        tmp, jmp = line.split(';')
        jmp = TABLE_J[jmp]
        line = jmp

        if tmp.include?('=') then dest, comp = tmp.split('=')
        else comp = tmp end

        dest = TABLE_D[dest]
        line = line + (dest << 3) unless dest.nil?

        if TABLE_C_A0.include? comp then comp = TABLE_C_A0[comp]
        else comp = TABLE_C_A1[comp]; line = line + 0x1000 end
        line = (comp.nil?) ? line : (line + (comp << 6))
        line = line + 0xE000
      end
      line = line.to_bin(16)
    end
  end

  def parse_symbols
    tmp = Hash.new
    i = 0
    @bar.each do |line|
      key = line.scan(/\(([^"]*)\)/).join()
      if key.empty? then i = i + 1; next end
      val = i; tmp[key] = i
    end
    @baz = tmp; tmp = Array.new
    @bar.each do |line|
      key = line.scan(/\(([^"]*)\)/).join()
      if key.empty? then tmp << line end
    end
    @bar = tmp
  end

  def prepare_addrs
    addr = 0x10
    @bar.map! do |line|
      key = line.scan(/\@([^"]*)/).join()
      tmp = (not key.empty?) ? @baz[key] : line
      if tmp.nil?
        if key[0] != 'R' and not key.numeric? and not TABLE_P.has_key? key
          TABLE_P[key] = addr; addr = addr + 1
        end
        line = line
      else
        line = tmp
      end
    end
  end

  def pre_clean
    tmp = Array.new
    @bar.each do |line|
      line.sub!(/\/\/.*/, ''); line.strip!
      tmp << line unless line.empty?
    end
    @bar = tmp
  end

  def out
    return @bar
  end

  private :parse_symbols, :prepare_addrs, :run_A_instruct, :run_C_instruct
end
