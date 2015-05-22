require_relative 'HackAssembler'

def main_process(filename)
  name = File.basename(filename, '.asm')
  asm = HackAssembler.new

  File.open(filename, 'r') do |f|
    f.each_line do |line|
      asm.read(line)
    end
  end

  File.open(File.join(File.dirname(filename), name + '.hack'), 'w') do |f|
    f.puts(asm.parse)
  end
end

ARGV.each do |filename|
  main_process(filename)
end

