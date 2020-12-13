module AoC::Year2020::Day12
  class Instruction
    attr_reader :action, :value

    def initialize(instruction)
      @instruction = instruction.match(/(?<action>\w)(?<value>\d+$)/)
      @action = @instruction[:action]
      @value = @instruction[:value].to_i
    end
  end

  class Travel
    attr_reader :instructions, :ferry

    def initialize(instructions)
      @instructions = instructions
      @ferry = Ferry.new
      @vertical_position = 0
      @horizontal_position = 0
    end

    def call
      instructions.each do |instruction|
        puts "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
        debug
        puts "Starting a move"
        puts "#{instruction.action} #{instruction.value}"

        case instruction.action
        when "N" then move_north(instruction.value) # Action N means to move north by the given value.
        when "S" then move_south(instruction.value) # Action S means to move south by the given value.
        when "E" then move_east(instruction.value)  # Action E means to move east by the given value.
        when "W" then move_west(instruction.value)  # Action W means to move west by the given value.
        when "L" then turn_left(instruction.value)  # Action L means to turn left the given number of degrees.
        when "R" then turn_right(instruction.value) # Action R means to turn right the given number of degrees.
        when "F" then forward(instruction.value)    # Action F means to move forward by the given value in the direction the ship is currently facing.
        end

        puts "Move done"
        debug
        puts "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
      end
    end

    def manhattan_distance
      horizontal_position.abs + vertical_position.abs
    end

    private

    def debug
      puts "Current position:"
      puts "Degrees: #{ferry.degrees}"
      puts "Direction: #{ferry.direction}"
      puts "Vertical Position: #{vertical_position}"
      puts "Horizontal Position: #{horizontal_position}"
    end

    attr_accessor :vertical_position, :horizontal_position

    def move_north(value)
      self.vertical_position -= value
    end

    def move_south(value)
      self.vertical_position += value
    end

    def move_east(value)
      self.horizontal_position += value
    end

    def move_west(value)
      self.horizontal_position -= value
    end

    def turn_left(value)
      ferry.turn(-value)
    end

    def turn_right(value)
      ferry.turn(value)
    end

    def forward(value)
      send("move_#{ferry.direction}", value)
    end
  end

  class TravelWithWaypoint
    attr_reader :instructions, :waypoint

    def initialize(instructions)
      @instructions = instructions
      @waypoint = { x: 10, y: -1 }
      @vertical_position = 0
      @horizontal_position = 0
    end

    def call
      instructions.each do |instruction|
        puts "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
        debug
        puts "Starting a move"
        puts "#{instruction.action} #{instruction.value}"

        case instruction.action
        when "N" then move_north(instruction.value) # Action N means to move north by the given value.
        when "S" then move_south(instruction.value) # Action S means to move south by the given value.
        when "E" then move_east(instruction.value)  # Action E means to move east by the given value.
        when "W" then move_west(instruction.value)  # Action W means to move west by the given value.
        when "L" then turn_left(instruction.value)  # Action L means to turn left the given number of degrees.
        when "R" then turn_right(instruction.value) # Action R means to turn right the given number of degrees.
        when "F" then forward(instruction.value)    # Action F means to move forward by the given value in the direction the ship is currently facing.
        end

        puts "Move done"
        debug
        puts "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
      end
    end

    def manhattan_distance
      horizontal_position.abs + vertical_position.abs
    end

    private

    def debug
      puts "Current position:"
      puts "Degrees: #{waypoint}"
      puts "Vertical Position: #{vertical_position}"
      puts "Horizontal Position: #{horizontal_position}"
    end

    attr_accessor :vertical_position, :horizontal_position

    def move_north(value)
      waypoint[:y] = waypoint[:y] - value
    end

    def move_south(value)
      waypoint[:y] = waypoint[:y] + value
    end

    def move_east(value)
      waypoint[:x] = waypoint[:x] + value
    end

    def move_west(value)
      waypoint[:x] = waypoint[:x] - value
    end

    def turn_left(value)
      turn(-value)
    end

    def turn_right(value)
      turn(value)
    end

    def turn(value)
      # Math.sin/cos want angles in radians
      absolute_radians_degrees = (value % 360) * Math::PI / 180
      x = waypoint[:x]
      y = waypoint[:y]

      waypoint[:x] = (x * Math.cos(absolute_radians_degrees) - y * Math.sin(absolute_radians_degrees)).round
      waypoint[:y] = (x * Math.sin(absolute_radians_degrees) + y * Math.cos(absolute_radians_degrees)).round
    end

    def forward(value)
      self.horizontal_position += (waypoint[:x] * value)
      self.vertical_position += (waypoint[:y] * value)
    end
  end

  class Ferry
    # Starting position
    #
    #            270
    #           North
    #             |
    #  180 West -   - East 0
    #             |
    #           South
    #             90

    attr_accessor :degrees

    def initialize
      @degrees = 0
    end

    def turn(degrees_value)
      new_degrees = (degrees + degrees_value) % 360
      self.degrees = new_degrees
    end

    def direction
      return 'east'  if degrees == 0
      return 'south' if degrees == 90
      return 'west'  if degrees == 180
      return 'north' if degrees == 270

      raise "Unexpected Ferry direction with #{degrees} degrees."
    end
  end

  class Part1
    def initialize(input = real_input)
      @input = input
    end

    def solution
      travel = Travel.new(instructions)
      travel.call
      travel.manhattan_distance
    end

    private

    def instructions
      @instructions ||= input.each_line.map { |instruction| Instruction.new(instruction) }
    end

    attr_reader :input

    def real_input
      @input ||= File.read("aoc/year2020/day12.txt")
    end
  end

  class Part2 < Part1
    def solution
      travel = TravelWithWaypoint.new(instructions)
      travel.call
      travel.manhattan_distance
    end
  end
end

RSpec.describe "Day 12" do
  let(:input) {
    <<~INPUT
F10
N3
F7
R90
F11
    INPUT
  }

  describe AoC::Year2020::Day12::Part1 do
    let(:instance) { described_class.new(input) }

    describe "#solution" do
      subject { instance.solution }

      it { is_expected.to be(25) }
    end
  end

  describe AoC::Year2020::Day12::Part2 do
    let(:instance) { described_class.new(input) }

    describe "#solution" do
      subject { instance.solution }

      it { is_expected.to be(286) }
    end
  end
end
