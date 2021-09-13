require 'csv'
require 'byebug'

def hex(num, rjust_len = 2)
    (num || 0).to_s(16).rjust(rjust_len, '0').upcase
end

filename = ARGV[0]
height = 0
width = nil
tiles = []

raise "File #{filename} not found" unless File.file?(filename)

CSV.foreach(filename) do |row|
    height += 1
    width ||= row.length
    row.each do |cell|
        tile = cell.to_i
        raise "Tile value too big" if tile > 0xff
        tiles << tile
    end
end

size = height * width

puts "#{width}x#{height} (#{size})"

File.open("#{File.basename(filename, '.csv')}.map", "w+b") do |file|
    file.write([tiles.map { |i| hex(i) }.join].pack('H*'))
end
