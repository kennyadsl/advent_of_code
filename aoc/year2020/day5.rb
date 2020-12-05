module AoC::Year2020::Day5
  class PartitioningToSeat
    attr_reader :partitioning

    def initialize(partitioning:)
      @partitioning = partitioning
    end

    def call
      SeatNumber.new(column: column, row: row)
    end

    private

    def column
      BinaryString.new(partitioning[0..-4], 'F').to_i
    end

    def row
      BinaryString.new(partitioning[-3..-1], 'L').to_i
    end
  end

  class SeatNumber
    attr_reader :column, :row

    def initialize(column:, row:)
      @column = column
      @row = row
    end

    def seat_id
      column * 8 + row
    end
  end

  class BinaryString
    attr_reader :string, :zero

    def initialize(string, zero)
      @string = string
      @zero = zero
    end

    def to_i
      string.each_char.map { |char| char == zero ? '0' : '1' }.join.to_i(2)
    end
  end

  class Part1
    def initialize(input = real_input)
      @input = input
    end

    def solution
      input.split.map do |partitioning_number|
        seat = PartitioningToSeat.new(partitioning: partitioning_number).call
        seat.seat_id
      end.max
    end

    private

    attr_reader :input

    def real_input
      @input ||= File.read("aoc/year2020/day5.txt")
    end
  end


  class Plane
    attr_reader :columns

    def initialize
      @columns = {}
    end

    def take_seat(seat)
      columns[seat.column] ||= PlaneRow.new
      columns[seat.column] << seat.row
    end

    def columns_with_missing_seats
      columns.select do |plane_column, plane_row|
        plane_row.missing_seats?
      end
    end
  end

  class PlaneRow
    attr_reader :seats
    def initialize
      @seats = []
    end

    def <<(value)
      seats << value
    end

    def missing_seats?
      missing_seats && regular_spots
    end

    def missing_seats
      @missing_seat ||= full_row - seats
    end

    private

    def regular_spots
      missing_seats.any? { |missing| seats.include?(missing + 1) && seats.include?(missing - 1) }
    end

    def full_row
      @full_row ||= [0,1,2,3,4,5,6,7]
    end
  end

  class Part2 < Part1
    def solution
      plane_seats = input.split.each_with_object(Plane.new) do |partitioning_number, plane|
        plane.take_seat(PartitioningToSeat.new(partitioning: partitioning_number).call)
      end

      column_with_missing_seat = plane_seats.columns_with_missing_seats.first
      missing_seat = SeatNumber.new(
        column: column_with_missing_seat.first,
        row: column_with_missing_seat.last.missing_seats.first
      )
      missing_seat.seat_id
    end
  end
end

RSpec.describe "Day 5" do
  let(:input) {
    <<~INPUT
FBFBBFFRLR
BFFFBBFRRR
FFFBBBFRRR
BBFFBBFRLL
    INPUT
  }

  describe AoC::Year2020::Day5::Part1 do
    let(:instance) { described_class.new(input) }

    describe "#solution" do
      subject { instance.solution }

      it 'returns the max seat id' do
        is_expected.to eq 820
      end
    end
  end

  describe AoC::Year2020::Day5::PartitioningToSeat do
    describe '#seat_id' do
      let(:instance) { described_class.new(partitioning: partitioning) }
      subject { instance.call.seat_id }
      let('partitioning') { 'FBFBBFFRLR' }

      it 'returns the max value in the list' do
        is_expected.to eq 357
      end
    end
  end

  describe AoC::Year2020::Day5::Part2 do
    let(:instance) { described_class.new(input) }

    describe "#solution" do
    # BFBFBFB LLL 000 0
    # BFBFBFB LLR 001 1
    # BFBFBFB LRL 010 2
    # BFBFBFB LRR 011 3
    # BFBFBFB RLL 100 4
    # BFBFBFB RLR 101 5
    # BFBFBFB RRL 110 6
    # BFBFBFB RRR 111 7
    # This input is a full column + another column (85) and will miss one row (6)
    let(:input) {
      <<~INPUT
BFBFBFFLLL
BFBFBFFLLR
BFBFBFFLRL
BFBFBFFLRR
BFBFBFFRLL
BFBFBFFRLR
BFBFBFFRRL
BFBFBFFRRR
BFBFBFBLLL
BFBFBFBLLR
BFBFBFBLRL
BFBFBFBLRR
BFBFBFBRLL
BFBFBFBRLR
BFBFBFBRRR
      INPUT
    }
      subject { instance.solution }

      it 'detect the missing seat' do
        is_expected.to eq(686) # (85 * 8 + 7)
      end
    end
  end
end
