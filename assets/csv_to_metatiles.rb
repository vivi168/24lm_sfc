require 'csv'
require 'byebug'

CHAR_SIZE = 2

def hex(num, rjust_len = 2)
    (num || 0).to_s(16).rjust(rjust_len, '0').upcase
end

def extract_sprites(map, width, height)
  sprite_per_row = width / CHAR_SIZE
  sprite_per_col = height / CHAR_SIZE
  sprite_per_sheet =  sprite_per_row * sprite_per_col

  sprites = []
  (0..sprite_per_sheet-1).each do |s|
    sprite = []
    (0..CHAR_SIZE-1).each do |r|
      offset = (s/sprite_per_row)*sprite_per_row * CHAR_SIZE**2 + s % sprite_per_row * CHAR_SIZE
      sprite += map[offset + r*sprite_per_row*CHAR_SIZE, CHAR_SIZE]
    end
    sprites.push(sprite)
  end

  sprites
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
        tile = 0xff if tile < 0
        tiles << tile
    end
end

size = height * width

puts "#{width}x#{height} (#{size})"

meta_tiles = extract_sprites(tiles, width, height)

meta_tiles.each_with_index do |meta_tile, i|
  puts "metatile_#{i.to_s.rjust(3, '0')}: .db #{meta_tile.map { |m| hex(m) }.join(',') }"
end

File.open("#{File.basename(filename, '.csv')}.bin", "w+b") do |file|
    file.write([meta_tiles.flatten.map { |i| hex(i) }.join].pack('H*'))
end
