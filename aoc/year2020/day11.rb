require "active_support/core_ext/object/duplicable"

module AoC::Year2020::Day11
  class OutsideMap
    def occupied?
      false
    end
  end

  class SeatStatus
    attr_reader :content

    def initialize(content:)
      @content = content
    end

    def empty?
      content == 'L'
    end

    def to_s
      content
    end

    def occupied?
      content == '#'
    end

    def floor?
      content == '.'
    end
  end

  class SeatsMap
    attr_reader :initial_layout
    attr_accessor :layout

    def initialize(layout:)
      @original_input = layout
      @initial_layout = layout.each_line.map { |line| line.delete_suffix("\n").chars }
      @layout = Array.new(lines_size) { |line| Array.new(rows_size) }
    end

    def at(line, row)
      return outsite_map if line >= lines_size
      return outsite_map if line < 0
      return outsite_map if row >= rows_size
      return outsite_map if row < 0

      content = layout[line][row] || initial_layout[line][row]
      SeatStatus.new(content: content)
    end

    def can_take?(line, row)
      at(line, row).empty? && adjacent_seats_for(line, row).none?(&:occupied?)
    end

    def should_leave?(line, row)
      at(line, row).occupied? && adjacent_seats_for(line, row).count(&:occupied?) >= leave_seat_threshold
    end

    def adjacent_seats_for(line, row)
      [
        at(line-1, row), # top
        at(line-1, row+1), # top-right
        at(line, row+1), # right
        at(line+1, row+1), # bottom-right
        at(line+1, row), # bottom
        at(line+1, row-1), # bottom-left
        at(line, row-1), # left
        at(line-1, row-1), # top-left
      ]
    end

    def take!(line, row)
      layout[line][row] = '#'
    end

    def free!(line, row)
      layout[line][row] = 'L'
    end

    def debug
      lines_size.times do |line|
        puts "\n"
        rows_size.times do |row|
          print at(line, row).content
        end
      end
    end

    def each
      lines_size.times do |line|
        rows_size.times do |row|
          yield(line, row)
        end
      end
    end

    def occupied
      occupied_count = 0

      lines_size.times do |line|
        rows_size.times do |row|
          occupied_count +=1 if at(line, row).occupied?
        end
      end

      occupied_count
    end

    def ==(other_seats_map)
      each do |line, row|
        return false if at(line, row).content != other_seats_map.at(line, row).content
      end

      true
    end

    def dup
      new_object = self.class.new(layout: @original_input)

      lines_size.times do |line|
        rows_size.times do |row|
          new_object.initial_layout[line][row] = at(line, row).content
        end
      end

      new_object
    end

    private

    def leave_seat_threshold
      4
    end

    def outsite_map
      @otuside_map ||= OutsideMap.new
    end

    def rows_size
      initial_layout.first.size
    end

    def lines_size
      initial_layout.size
    end
  end

  class SeatsMapStrict < SeatsMap
    def adjacent_seats_for(line, row)
      directions = {
        'top':          { line: -1, row: 0   },
        'top-right':    { line: -1, row: +1  },
        'right':        { line: 0,  row: +1  },
        'bottom-right': { line: +1, row: +1  },
        'bottom':       { line: +1, row: 0   },
        'bottom-left':  { line: +1, row: -1  },
        'left':         { line: 0,  row: -1  },
        'top-left':     { line: -1, row: -1  },
      }

      directions.map do |name, increments|
        first_seat = nil
        current_line = line
        current_row = row

        loop do
          next_line = current_line + increments[:line]
          next_row = current_row + increments[:row]

          seat = at(next_line, next_row)

          break if seat.is_a? OutsideMap

          if seat.floor?
            current_line = next_line
            current_row = next_row
          else
            first_seat = seat
            break
          end
        end

        first_seat
      end.compact
    end

    private

    def leave_seat_threshold
      5
    end
  end

  class Part1
    def initialize(input = real_input)
      @input = input
    end

    def solution
      seats_map = seats_map_class.new(layout: input)

      previous_seats_map = seats_map
      new_seats_map = nil

      loop do
        new_seats_map = previous_seats_map.dup

        previous_seats_map.each do |line, row|
          new_seats_map.take!(line, row) if previous_seats_map.can_take?(line, row)
          new_seats_map.free!(line, row) if previous_seats_map.should_leave?(line, row)
        end

        break if previous_seats_map == new_seats_map
        previous_seats_map = new_seats_map
      end

      new_seats_map.occupied
    end

    private

    attr_reader :input

    def seats_map_class
      SeatsMap
    end

    def real_input
      @input ||= File.read("aoc/year2020/day11.txt")
    end
  end

  class Part2 < Part1
    private

    def seats_map_class
      SeatsMapStrict
    end
  end
end

RSpec.describe "Day 11" do
  let(:input) {
    <<~INPUT
L.LL.LL.LL
LLLLLLL.LL
L.L.L..L..
LLLL.LL.LL
L.LL.LL.LL
L.LLLLL.LL
..L.L.....
LLLLLLLLLL
L.LLLLLL.L
L.LLLLL.LL
    INPUT
  }

  describe AoC::Year2020::Day11::Part1 do
    let(:instance) { described_class.new(input) }

    describe "#solution" do
      subject { instance.solution }

      it { is_expected.to be(37) }
    end
  end

  describe AoC::Year2020::Day11::Part2 do
    let(:instance) { described_class.new(input) }

    describe "#solution" do
      subject { instance.solution }

      it { is_expected.to be(26) }
    end
  end
end
