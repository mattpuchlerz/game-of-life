module GameOfLife
  class Grid
    
    attr_reader :cells
    
    def initialize seed
      @cells = seed
    end
    
    def live_neighbor_count_of row, col
      neighbors_of(row, col).select { |c| c == 1 }.count
    end
    
    def neighbors_of row, col
      [ status_of(row-1, col-1), status_of(row-1, col), status_of(row-1, col+1),
        status_of(row,   col-1),                        status_of(row,   col+1), 
        status_of(row+1, col-1), status_of(row+1, col), status_of(row+1, col+1) ]
    end
    
    def new_generation
      pad_cells
      new_cells = []
      @cells.each_with_index do |cols, row_id|
        new_cells[row_id] = []
        cols.each_with_index do |col, col_id|
          new_cells[row_id][col_id] = new_status_of row_id, col_id
        end
      end
      @cells = new_cells
    end
    
    def new_status_of row, col
      count  = live_neighbor_count_of row, col
      status = status_of row, col
      ( count == 3 or ( count == 2 and status == 1 ) ) ? 1 : 0
    end
    
    def status_of row, col
      return 0 if row < 0 or col < 0
      @cells[row][col] || 0 rescue 0
    end
    
    private
    
    def pad_cells
      top = @cells.first.join
      @cells.unshift Array.new(@cells.first.length).fill(0) if top =~ /111/
      
      bottom = @cells.last.join
      @cells << Array.new(@cells.last.length).fill(0) if bottom =~ /111/
      
      left = @cells.inject('') { |str, c| str += c.first.to_s } 
      @cells.each { |c| c.unshift 0 } if left =~ /111/
      
      right = @cells.inject('') { |str, c| str += c.last.to_s } 
      @cells.each { |c| c << 0 } if right =~ /111/
    end
    
  end
end