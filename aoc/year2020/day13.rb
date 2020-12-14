module AoC::Year2020::Day13
  class Part1
    def initialize(input = real_input)
      @input = input
    end

    def solution
      arrival_time = input.lines[0].to_i
      available_buses = input.lines[1].split(',').map(&:to_i).reject { |b| b == 0 }

      first_bus = nil
      time = arrival_time

      loop do
        first_bus = available_buses.find { |bus| time % bus == 0 }
        break if first_bus != nil
        time += 1
      end

      wait_time = time - arrival_time
      wait_time * first_bus

    end

    private

    attr_reader :input

    def real_input
      @input ||= File.read("aoc/year2020/day13.txt")
    end
  end

  class Part2 < Part1
    def solution
      available_buses = input.lines[1].split(',').map(&:to_i).each_with_index.reject { |b, _i| b == 0 }

      step = 1
      time = 0
      evaluated_buses = []

      available_buses.each do |bus|
        evaluated_buses << bus
        until evaluated_buses.all? { |bus, offset| (time + offset) % bus == 0 } do
          time += step
        end

        step = step * bus[0]
      end

      time
    end
  end
end

RSpec.describe "Day 13" do
  let(:input) {
    <<~INPUT
939
7,13,x,x,59,x,31,19
    INPUT
  }

  describe AoC::Year2020::Day13::Part1 do
    let(:instance) { described_class.new(input) }

    describe "#solution" do
      subject { instance.solution }

      it { is_expected.to be(295) }
    end
  end

  describe AoC::Year2020::Day13::Part2 do
    let(:instance) { described_class.new(input) }

    describe "#solution" do
      subject { instance.solution }

      it { is_expected.to be(1068781) }
    end
  end
end
