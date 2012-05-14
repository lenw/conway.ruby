class Conway

  def initialize
    @grid = Hash.new
    @rows = 12
    @cols = 30
    new_life
  end

  def new_life
    process_grid do |r, c|
      #puts "r = #{r}, c = #{c}"
      @grid[[r, c]] = Random.rand(100) > 30 ? true : false
    end
  end

  def process_grid
    for r in 0..@rows do
      for c in 0..@cols do
        yield r, c
      end
    end
  end


  def display
    for r in 0..@rows do
      print "\n"
      for c in 0..@cols do
        print @grid[[r, c]] == true ? "X " : "O "
      end
    end
  end

  def generate
    new_grid = Hash.new
    process_grid do |r, c|
      count = count_neighbours r, c
      #puts "#{r}, #{c} = #{count}"
      if @grid[[r, c]] && count <= 2
        new_grid[[r, c]] = false # starvation
      elsif @grid[[r, c]] && (count == 3 || count == 2)
        new_grid[[r, c]] = true # happy
      elsif @grid[[r, c]] && count > 3
        new_grid[[r, c]] = false # overcrowding
      elsif !@grid[[r, c]] && count > 3
        new_grid[[r, c]] = false # rebirth
      end
    end
    @grid = new_grid
  end

  def count_neighbours r, c
    count = 0
    for i in r-1 .. r+1
      for j in c-1 .. c+1
        count = count + 1 unless i < 0 || j < 0 || i > @rows || j > @cols || (i == r && j == c) || @grid[[i, j]]
      end
    end
    return count
  end

  def total_alive
    count = 0
    process_grid do |r, c|
      count = count + 1 if @grid[[r, c]]
    end
    return count
  end

end

c = Conway.new
gen = 1
longest = 1
current = 1

Signal.trap :EXIT do
  puts "\n\nEnding"
  puts "Longest lived initial generation was #{longest} cycles "
end


while true do
  puts "\n----------"
  puts "Generation #{gen}, alive = #{c.total_alive}, survival = #{current}, longest = #{longest}"
  gen = gen + 1
  c.display
  begin
    sleep 1
  rescue Exception => e
    exit
  end
  if c.total_alive < 2
    puts "\n----------"
    puts "Everything died in generation #{gen}"
    puts "Let there be new life !"
    puts "\n----------"
    c.new_life
    if current > longest
      longest = current
      current = 0
    end
  end
  c.generate
  current = current + 1
end

