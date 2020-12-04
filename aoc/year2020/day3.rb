module AoC::Year2020::Day3
  class Part1
    def initialize(input = real_input)
      @input = input
    end

    def solution
      trajectory = Trajectory.new(
        direction: direction,
        map: map,
      )

      trajectory.call
      trajectory.trees
    end

    private

    attr_reader :input

    def direction
      Direction.new(right: 3, down: 1)
    end

    def map
      Map.new(geology: input)
    end

    def real_input
      @input ||= File.read("aoc/year2020/day3.txt")
    end
  end

  class Part2 < Part1
    def solution
      [
        Direction.new(right: 1, down: 1),
        Direction.new(right: 3, down: 1),
        Direction.new(right: 5, down: 1),
        Direction.new(right: 7, down: 1),
        Direction.new(right: 1, down: 2),
      ].map do |direction|
        trajectory = Trajectory.new(
          direction: direction,
          map: map,
        )

        trajectory.call
        trajectory.trees
      end.inject(&:*)
    end
  end

  class Direction
    attr_reader :right, :down

    def initialize(right:, down:)
      @right = right
      @down = down
    end
  end

  class Map
    attr_reader :geology

    def initialize(geology:)
      @geology = geology.each_line.map { |line| line.delete_suffix("\n").chars }
    end

    def at(line, row)
      return nil if line >= lines_size

      Point.new(content: geology[line][normalized_row(row)])
    end

    private

    def normalized_row(row)
      row % rows_size
    end

    def rows_size
      geology.first.size
    end

    def lines_size
      geology.size
    end
  end

  class Trajectory
    attr_reader :direction, :map, :trees, :current_line, :current_row

    def initialize(direction:, map:)
      @direction = direction
      @map = map
      @trees = 0

      @current_line = 0
      @current_row = 0
    end

    def call
      while current_position
        @trees += 1 if current_position.tree?

        next_position
      end
    end

    private

    def current_position
      map.at(current_line, current_row)
    end

    def next_position
      @current_line += direction.down
      @current_row += direction.right
    end
  end

  class Point
    attr_reader :content

    def initialize(content:)
      @content = content
    end

    def tree?
      content == "#"
    end

    def square?
      !tree?
    end

    def to_s
      content
    end
  end
end

RSpec.describe "Day 3" do
  let(:input) {
    <<~INPUT
..##.......
#...#...#..
.#....#..#.
..#.#...#.#
.#...##..#.
..#.##.....
.#.#.#....#
.#........#
#.##...#...
#...##....#
.#..#...#.#
    INPUT
  }

  describe AoC::Year2020::Day3::Part1 do
    let(:instance) { described_class.new(input) }

    describe "#solution" do
      subject { instance.solution }

      it "finds seven trees in the map" do
        is_expected.to be 7
      end
    end
  end

  describe AoC::Year2020::Day3::Part2 do
    let(:instance) { described_class.new(input) }

    describe "#solution" do
      subject { instance.solution }

      it "correclty calculate the solution" do
        is_expected.to be 336
      end
    end
  end

  describe AoC::Year2020::Day3::Point do
    let(:instance) { described_class.new(content: content_v) }

    describe "#tree?" do
      subject { instance.tree? }

      context "when its content is #" do
        let(:content_v) { "#" }

        it "returns true" do
          is_expected.to be_truthy
        end
      end
    end
  end

  describe AoC::Year2020::Day3::Map do
    let(:instance) { described_class.new(geology: input) }

    describe "#at?" do
      it 'is a square when .' do
        expect(instance.at(0, 0)).to be_square
      end

      it 'is a tree when #' do
        expect(instance.at(0, 2)).to be_tree
      end

      it 'is horizontally infinite' do
        expect(instance.at(0, 11)).to be_square
        expect(instance.at(0, 12)).to be_square
        expect(instance.at(0, 13)).to be_tree
        expect(instance.at(0, 14)).to be_tree
        expect(instance.at(0, 15)).to be_square
      end

      it 'is vertically finite' do
        expect(instance.at(10, 0)).to be_square
        expect(instance.at(11, 0)).to be_nil
      end
    end
  end
end
