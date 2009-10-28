require 'lib/game_of_life'

def grid_seed_from(string)
  string.split("\n").inject([]) do |arr, row|
    arr << row.split('').map { |cell| cell == 'X' ? 1 : 0 }
  end
end

if __FILE__ == $0
  require 'rubygems'
  require 'ffi-ncurses'  
  
  filename = ARGV.empty? ? 'default.pat' : ARGV.first
  file = File.exists?(File.expand_path(filename)) ? filename : File.join('./patterns', filename)
  grid_string = File.open(file).read

  begin
    stdscr = FFI::NCurses.initscr
    FFI::NCurses.clear
    
    game = GameOfLife::Game.new grid_seed_from(grid_string)
    i = 0
    loop do
      i += 1
      FFI::NCurses.addstr "Generation: #{i}\n"
      FFI::NCurses.addstr game.to_s( :live => 'o', :dead => ' ' )
      FFI::NCurses.refresh
      FFI::NCurses.clear
      game.new_generation
      sleep 0.25
    end
  ensure
    FFI::NCurses.endwin
  end  
  
end