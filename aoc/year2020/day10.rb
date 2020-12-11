module AoC::Year2020::Day10
  class ConnectionPoint
    attr_reader :joltage

    def initialize(joltage:)
      @joltage = joltage
    end

    def plaggable_to?(another_connection_point)
      compatible_joltage.include? another_connection_point.joltage
    end

    def plaggable_combinations(connection_points)
      connection_points.map.with_index do |connection_point, index|
        if plaggable_to?(connection_point)
          connection_points[index..connection_points.length]
        else
          nil
        end
      end.compact
    end

    private

    def compatible_joltage
      (joltage + 1..joltage + 3)
    end
  end

  class Connection
    attr_reader :input, :output

    def initialize(input:, output:)
      @input = input
      @output = output
    end

    def three_jolt_difference?
      output - input == 3
    end

    def one_jolt_difference?
      output - input == 1
    end
  end

  class Part1
    def initialize(input = real_input)
      @input = input.each_line.map(&:to_i)
    end

    def solution
      connections.select(&:three_jolt_difference?).count * connections.select(&:one_jolt_difference?).count
    end

    private

    attr_reader :input

    def connections
      @connections ||= all_connection_points.each_with_object([]).with_index do |(connection_point, memo), index|
        next if index == all_connection_points.length - 1

        next_connection_point = all_connection_points[index+1..all_connection_points.length].find { |tentative_connection_point| connection_point.plaggable_to?(tentative_connection_point) }

        memo << Connection.new(
          input: connection_point.joltage,
          output: next_connection_point.joltage
        )
      end

      @connections
    end

    def all_connection_points
      @all_connection_points ||= [].tap do |connection_points|
        connection_points << power_source
        connection_points << adapters
        connection_points << device
      end.flatten
    end

    def adapters
      input.sort.map { |adapter_input| ConnectionPoint.new(joltage: adapter_input)}
    end

    def power_source
      @power_source ||= ConnectionPoint.new(joltage: 0)
    end

    def device
      @device ||= begin
        device_built_in_adapter_input = adapters.last.joltage + 3
        ConnectionPoint.new(joltage: device_built_in_adapter_input)
      end
    end

    def real_input
      @input ||= File.read("aoc/year2020/day10.txt")
    end
  end

  class Part2 < Part1
    def solution
      @counter = 0
      combinations(all_connection_points)
    end

    def combinations(remaining)
      return 1 if remaining.first == device

      remaining.first.plaggable_combinations(remaining).map do |combination|
        @combinations_cache ||= {}
        @combinations_cache[combination.first.joltage] ||= combinations(combination)
      end.sum
    end
  end
end

RSpec.describe "Day 10" do
  let(:input) {
    <<~INPUT
28
33
18
42
31
14
46
20
48
47
24
23
49
45
19
38
39
11
1
32
25
35
8
17
7
9
4
2
34
10
3
    INPUT
  }

  describe AoC::Year2020::Day10::Part1 do
    let(:instance) { described_class.new(input) }

    describe "#solution" do
      subject { instance.solution }

      it { is_expected.to be(220) }
    end
  end

  describe AoC::Year2020::Day10::Part2 do
    let(:instance) { described_class.new(input) }

    describe "#solution" do
      subject { instance.solution }

      xit { is_expected.to be(19208) }

      context "with another input" do
        let(:input) {
          <<~INPUT
16
10
15
5
1
11
7
19
6
12
4
          INPUT
        }
        xit { is_expected.to be(8) }
      end
    end
  end
end
