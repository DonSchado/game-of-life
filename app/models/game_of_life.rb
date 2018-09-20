class GameOfLife
  include ActiveModel::Model
  include Enumerable

  ROWS    = 16
  COLUMNS = 12
  EXAMPLE = '0010001000001010001000000110001000000000000000000000000000000000000000000000000000000000000'\
            '00000001000000000001000000000001000000000001000000000001000000000111110000000011100000000001'

  attr_reader :cells, :rows, :columns

  def initialize(options = {})
    @rows    = (options[:rows]    || ROWS).to_i.clamp(1, ROWS)
    @columns = (options[:columns] || COLUMNS).to_i.clamp(1, COLUMNS)
    @cells   = (options[:state]   || EXAMPLE).ljust(board_size, '0')[0...board_size].chars.map(&valid_state)
  end

  def generation
    @cells = cells.each_with_index.map do |cell, index|
      rules(cell_state: cell, neighbors_count: neighbors_count(index))
    end

    self
  end

  def each(&block)
    cells.each(&block)
  end

  def board_size
    columns * rows
  end

  # virtual board on a 1-dimensional array
  def linebreak?(cell)
    cell.nonzero? && (cell % columns).zero?
  end

  def to_partial_path
    'game_of_life'
  end

  private

  def valid_state
    ->(char) { [char.to_i, 1].min } # only 0 & 1
  end

  def rules(cell_state:, neighbors_count:)
    return 1 if neighbors_count == 3                    # IT'S ALIVE! (rule 4)
    return 1 if [cell_state, neighbors_count] == [1, 2] # unchanged (rule 3)
    0                                                   # under-/overpopulation (rules 1+2)
  end

  # nw n ne
  # w [i] e
  # sw s se
  def neighbors_count(i)
    n  = relative(i-columns, 0)
    s  = relative(i+columns, 0)
    e  = relative(i, +1)
    w  = relative(i, -1)
    nw = relative(n, -1)
    ne = relative(n, +1)
    sw = relative(s, -1)
    se = relative(s, +1)

    cells.values_at(*[n, nw, ne, e, w, s, sw, se].compact).sum
  end

  # enforces boundaries at the "board borders"
  def relative(reference_point, distance)
    return if reference_point.nil? # there is no cell
    return if (reference_point + distance) >= board_size # out of bound +
    return if (reference_point + distance).negative?     # out of bound -

    # calculate possible move
    reference_point/columns == (reference_point + distance)/columns ? (reference_point + distance) : nil
  end
end
