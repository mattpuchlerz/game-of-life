module GameOfLife
  class Game
    
    attr_reader :grid
    
    def initialize grid_seed
      @grid = grid_seed
    end
    
    def live_neighbor_count_of row, col
      neighbors_of(row, col).select { |cell| cell == 1 }.count
    end
    
    def neighbors_of row, col
      [ status_of(row-1, col-1), status_of(row-1, col), status_of(row-1, col+1),
        status_of(row,   col-1),                        status_of(row,   col+1), 
        status_of(row+1, col-1), status_of(row+1, col), status_of(row+1, col+1) ]
    end
    
    def new_generation
      pad_grid
      new_grid = []
      @grid.each_with_index do |cols, row_id|
        new_grid[row_id] = []
        cols.each_with_index do |col, col_id|
          new_grid[row_id][col_id] = new_status_of row_id, col_id
        end
      end
      @grid = new_grid
    end
    
    def new_status_of row, col
      count  = live_neighbor_count_of row, col
      status = status_of row, col
      ( count == 3 or ( count == 2 and status == 1 ) ) ? 1 : 0
    end
    
    def status_of row, col
      return 0 if row < 0 or col < 0
      @grid[row][col] || 0 rescue 0
    end
    
    private
    
    def pad_grid
      top = @grid.first.join
      @grid.unshift Array.new(@grid.first.length).fill(0) if top =~ /111/
      
      bottom = @grid.last.join
      @grid << Array.new(@grid.last.length).fill(0) if bottom =~ /111/
      
      left = @grid.inject('') { |str, grid| str += grid.first.to_s } 
      @grid.each { |row| row.unshift 0 } if left =~ /111/
      
      right = @grid.inject('') { |str, grid| str += grid.last.to_s } 
      @grid.each { |row| row << 0 } if right =~ /111/
    end
    
  end
end