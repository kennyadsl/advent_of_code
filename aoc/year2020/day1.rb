module AoC::Year2020::Day1
  class Part1
    def initialize(input = real_input)
      @input = input
    end

    def solution
      input.split.map(&:to_i).combination(combination_size).find { |x| x.sum == 2020 }.inject(&:*)
    end

    def combination_size
      2
    end

    private

    attr_reader :input

    def real_input
      @input ||= File.read("aoc/year2020/day1.txt")
    end
  end

  class Part2 < Part1
    private

    def combination_size
      3
    end
  end
end

RSpec.describe "Day 1" do
  let(:input) {
    <<~INPUT
2017
33
1
2
2019
    INPUT
  }

  describe AoC::Year2020::Day1::Part1 do
    let(:instance) { described_class.new(input) }

    describe "#solution" do
      subject { instance.solution }

      it { is_expected.to eq 2019 }
    end
  end

  describe AoC::Year2020::Day1::Part2 do
    let(:instance) { described_class.new(input) }

    describe "#solution" do
      subject { instance.solution }

      it { is_expected.to eq 4034 }
    end
  end
end
