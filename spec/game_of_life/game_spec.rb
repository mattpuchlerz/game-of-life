require File.join( File.dirname(__FILE__), '..', 'spec_helper' )

describe GameOfLife::Game do
  
  def default_grid
    [ [ 0, 0, 0 ],
      [ 1, 0, 0 ],
      [ 1, 1, 0 ],
      [ 1, 1, 1 ] ]
  end
  
  describe "initializing" do
    
    it "should be initialized with a seed, which is a grid to start from" do
      game = GameOfLife::Game.new default_grid
    end
  
    it "should keep track of the grid" do
      game = GameOfLife::Game.new default_grid
      game.grid.should == default_grid
    end
  
  end
  
  describe "working with the grid's cells" do
    
    before :each do
      @game = GameOfLife::Game.new default_grid      
    end
    
    it "should get a cell's current status" do
      @game.status_of(0, 0).should == 0
      @game.status_of(1, 0).should == 1
    end
  
    it "should assume a status of dead if requested cell does not exist" do
      @game.status_of( -1,   0).should == 0
      @game.status_of( -1,  -1).should == 0
      @game.status_of(  0,  -1).should == 0
      @game.status_of(  0, 100).should == 0
      @game.status_of(100,  -1).should == 0
      @game.status_of(100,   0).should == 0
      @game.status_of(100, 100).should == 0
    end
  
    it "should get a cell's neighbors" do
      @game.neighbors_of(0, 0).should == [ 0, 0, 0, 
                                           0,    0, 
                                           0, 1, 0 ]
      @game.neighbors_of(1, 1).should == [ 0, 0, 0, 
                                           1,    0, 
                                           1, 1, 0 ]
      @game.neighbors_of(2, 0).should == [ 0, 1, 0, 
                                           0,    1, 
                                           0, 1, 1 ]
    end
    
    it "should get a cell's live neighbor count" do
      @game.live_neighbor_count_of(0, 0).should == 1
      @game.live_neighbor_count_of(0, 1).should == 1
      @game.live_neighbor_count_of(1, 0).should == 2
      @game.live_neighbor_count_of(1, 1).should == 3
      @game.live_neighbor_count_of(2, 0).should == 4
      @game.live_neighbor_count_of(2, 1).should == 5
    end
  
    describe "determining a cell's new status" do

      it "should kill a cell that has fewer than 2 live neighbors" do
        @game.should_receive(:live_neighbor_count_of).with(0, 0).and_return 1
        @game.new_status_of(0, 0).should == 0
      end

      it "should kill a cell that has more than 3 live neighbors" do
        @game.should_receive(:live_neighbor_count_of).with(0, 0).and_return 4
        @game.new_status_of(0, 0).should == 0
      end

      it "should keep a cell alive that has 2 live neighbors" do
        @game.should_receive(:status_of).with(0, 0).and_return 1
        @game.should_receive(:live_neighbor_count_of).with(0, 0).and_return 2
        @game.new_status_of(0, 0).should == 1
      end

      it "should keep a cell alive that has 3 live neighbors" do
        @game.should_receive(:status_of).with(0, 0).and_return 1
        @game.should_receive(:live_neighbor_count_of).with(0, 0).and_return 3
        @game.new_status_of(0, 0).should == 1
      end

      it "should resuscitate a dead cell that has 3 live neighbors" do
        @game.should_receive(:status_of).with(0, 0).and_return 0
        @game.should_receive(:live_neighbor_count_of).with(0, 0).and_return 3
        @game.new_status_of(0, 0).should == 1
      end

      it "should not resuscitate a dead cell that has 2 live neighbors" do
        @game.should_receive(:status_of).with(0, 0).and_return 0
        @game.should_receive(:live_neighbor_count_of).with(0, 0).and_return 2
        @game.new_status_of(0, 0).should == 0
      end

    end
  
  end
  
  describe "creating a new generation" do
    
    it "should create a new generation of cells using their new status" do
      game = GameOfLife::Game.new default_grid
      game.new_generation
      game.grid.should == [ [ 0, 0, 0, 0 ],
                            [ 0, 1, 1, 0 ],
                            [ 1, 0, 0, 1 ],
                            [ 0, 1, 0, 1 ],
                            [ 0, 0, 1, 0 ] ]
    end
    
    describe "automatic expansion of the grid" do
      
      it "should add a row on the top when the topmost row has 3 adjacent live cells" do
        game = GameOfLife::Game.new [ [ 0, 1, 1, 1, 0 ],
                                      [ 0, 0, 0, 0, 0 ] ]
        game.new_generation
        game.grid.should ==         [ [ 0, 0, 1, 0, 0 ],
                                      [ 0, 0, 1, 0, 0 ],
                                      [ 0, 0, 1, 0, 0 ] ]
      end
      
      it "should add a row on the bottom when the bottommost row 3 consecutive live cells" do
        game = GameOfLife::Game.new [ [ 0, 0, 0, 0, 0 ],
                                      [ 0, 1, 1, 1, 0 ] ]
        game.new_generation
        game.grid.should ==         [ [ 0, 0, 1, 0, 0 ],
                                      [ 0, 0, 1, 0, 0 ],
                                      [ 0, 0, 1, 0, 0 ] ]
      end
      
      it "should add a column on the left when the leftmost column has 3 adjacent live cells" do
        game = GameOfLife::Game.new [ [ 0, 0 ],
                                      [ 1, 0 ],
                                      [ 1, 0 ],
                                      [ 1, 0 ],
                                      [ 0, 0 ] ]
        game.new_generation
        game.grid.should ==         [ [ 0, 0, 0 ],
                                      [ 0, 0, 0 ],
                                      [ 1, 1, 1 ],
                                      [ 0, 0, 0 ],
                                      [ 0, 0, 0 ] ]
      end
      
      it "should add a column on the right when the rightmost column has 3 adjacent live cells" do
        game = GameOfLife::Game.new [ [ 0, 0 ],
                                      [ 0, 1 ],
                                      [ 0, 1 ],
                                      [ 0, 1 ],
                                      [ 0, 0 ] ]
        game.new_generation
        game.grid.should ==         [ [ 0, 0, 0 ],
                                      [ 0, 0, 0 ],
                                      [ 1, 1, 1 ],
                                      [ 0, 0, 0 ],
                                      [ 0, 0, 0 ] ]
      end
      
    end
    
    describe "still lives" do
      
      after :each do
        game = GameOfLife::Game.new @gen1
        game.new_generation
        game.grid.should == @gen1        
      end
      
      it "should maintain the 'block'" do
        @gen1 = [ [ 0, 0, 0, 0 ],
                  [ 0, 1, 1, 0 ],
                  [ 0, 1, 1, 0 ],
                  [ 0, 0, 0, 0 ] ]
      end
    
      it "should maintain the 'beehive'" do
        @gen1 = [ [ 0, 0, 0, 0, 0, 0 ],
                  [ 0, 0, 1, 1, 0, 0 ],
                  [ 0, 1, 0, 0, 1, 0 ],
                  [ 0, 0, 1, 1, 0, 0 ],
                  [ 0, 0, 0, 0, 0, 0 ] ]
      end
    
      it "should maintain the 'loaf'" do
        @gen1 = [ [ 0, 0, 0, 0, 0, 0 ],
                  [ 0, 0, 1, 1, 0, 0 ],
                  [ 0, 1, 0, 0, 1, 0 ],
                  [ 0, 0, 1, 0, 1, 0 ],
                  [ 0, 0, 0, 1, 0, 0 ],
                  [ 0, 0, 0, 0, 0, 0 ] ]
      end
    
      it "should maintain the 'boat'" do
        @gen1 = [ [ 0, 0, 0, 0, 0 ],
                  [ 0, 1, 1, 0, 0 ],
                  [ 0, 1, 0, 1, 0 ],
                  [ 0, 0, 1, 0, 0 ],
                  [ 0, 0, 0, 0, 0 ] ]
      end
    
    end
    
    describe "oscillators" do
      
      after :each do
        game = GameOfLife::Game.new @gen1
        game.new_generation
        game.grid.should == @gen2
        game.new_generation
        game.grid.should == @gen1
      end
      
      it "should oscillate the 'blinker'" do
        @gen1 = [ [ 0, 0, 0, 0, 0 ],
                  [ 0, 0, 1, 0, 0 ],
                  [ 0, 0, 1, 0, 0 ],
                  [ 0, 0, 1, 0, 0 ],
                  [ 0, 0, 0, 0, 0 ] ]
        @gen2 = [ [ 0, 0, 0, 0, 0 ],
                  [ 0, 0, 0, 0, 0 ],
                  [ 0, 1, 1, 1, 0 ],
                  [ 0, 0, 0, 0, 0 ],
                  [ 0, 0, 0, 0, 0 ] ]
      end
    
      it "should oscillate the 'toad'" do
        @gen1 = [ [ 0, 0, 0, 0, 0, 0 ],
                  [ 0, 0, 0, 0, 0, 0 ],
                  [ 0, 0, 1, 1, 1, 0 ],
                  [ 0, 1, 1, 1, 0, 0 ],
                  [ 0, 0, 0, 0, 0, 0 ],
                  [ 0, 0, 0, 0, 0, 0 ] ]
        @gen2 = [ [ 0, 0, 0, 0, 0, 0 ],
                  [ 0, 0, 0, 1, 0, 0 ],
                  [ 0, 1, 0, 0, 1, 0 ],
                  [ 0, 1, 0, 0, 1, 0 ],
                  [ 0, 0, 1, 0, 0, 0 ],
                  [ 0, 0, 0, 0, 0, 0 ] ]
      end
    
      it "should oscillate the 'beacon'" do
        @gen1 = [ [ 0, 0, 0, 0, 0, 0 ],
                  [ 0, 1, 1, 0, 0, 0 ],
                  [ 0, 1, 0, 0, 0, 0 ],
                  [ 0, 0, 0, 0, 1, 0 ],
                  [ 0, 0, 0, 1, 1, 0 ],
                  [ 0, 0, 0, 0, 0, 0 ] ]
        @gen2 = [ [ 0, 0, 0, 0, 0, 0 ],
                  [ 0, 1, 1, 0, 0, 0 ],
                  [ 0, 1, 1, 0, 0, 0 ],
                  [ 0, 0, 0, 1, 1, 0 ],
                  [ 0, 0, 0, 1, 1, 0 ],
                  [ 0, 0, 0, 0, 0, 0 ] ]
      end
    
    end

    describe "spaceships" do
      
      before :each do
        @generations = []
      end
      
      after :each do
        game = GameOfLife::Game.new @generations[0]
        @generations.length.times do |i|
          next if i == 0
          game.new_generation
          game.grid.should == @generations[i]
        end
      end
      
      it "should move the 'glider'" do
        @generations[0] = [ [ 0, 0, 1 ],
                            [ 1, 0, 1 ],
                            [ 0, 1, 1 ] ]
                  
        @generations[1] = [ [ 0, 1, 0, 0 ],
                            [ 0, 0, 1, 1 ],
                            [ 0, 1, 1, 0 ] ]
                  
        @generations[2] = [ [ 0, 0, 1, 0 ],
                            [ 0, 0, 0, 1 ],
                            [ 0, 1, 1, 1 ] ]
                  
        @generations[3] = [ [ 0, 0, 0, 0 ],
                            [ 0, 1, 0, 1 ],
                            [ 0, 0, 1, 1 ],
                            [ 0, 0, 1, 0 ] ]

        @generations[4] = [ [ 0, 0, 0, 0 ],
                            [ 0, 0, 0, 1 ],
                            [ 0, 1, 0, 1 ],
                            [ 0, 0, 1, 1 ] ]
      end
      
    end
    
  end
  
  describe "output" do
    
    before :each do
      @game = GameOfLife::Game.new default_grid
    end
    
    it "should return the grid as a formatted string" do
      @game.to_s.should == "000\n100\n110\n111"
    end
    
    it "should accept an option to change the representation of a live cell" do
      @game.to_s(:live => 'X').should == "000\nX00\nXX0\nXXX"
    end
    
    it "should accept an option to change the representation of a dead cell" do
      @game.to_s(:dead => 'X').should == "XXX\n1XX\n11X\n111"
    end
    
  end
  
end