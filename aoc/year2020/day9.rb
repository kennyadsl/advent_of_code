module AoC::Year2020::Day9
  class ValidityRange
    attr_reader :numbers, :index, :range_size, :combo_size, :preamble

    def initialize(numbers:, index:, range_size:, combo_size: 2, preamble: true)
      @numbers = numbers
      @index = index
      @range_size = range_size
      @combo_size = combo_size
      @preamble = preamble
    end

    def sums
      numbers_in_range.combination(combo_size).map(&:sum)
    end

    def preamble?
      preamble && index < range_size
    end

    private

    def numbers_in_range
      numbers[range_start..range_end]
    end

    def range_start
      index - range_size
    end

    def range_end
      index - 1
    end
  end

  class ValidNumber
    attr_reader :number, :validity_range

    def initialize(number, validity_range)
      @number = number
      @validity_range = validity_range
    end

    def valid?
      return true if validity_range.preamble?

      validity_range.sums.include? number
    end
  end

  class Part1
    def initialize(input = real_input, range_size: 25)
      @input = input
      @numbers = input.each_line.map(&:to_i)
      @range_size = range_size
    end

    def solution
      numbers.each_with_index.find do |number, index|
        !ValidNumber.new(
          number,
          ValidityRange.new(
            numbers: numbers,
            index: index,
            range_size: range_size
          )
        ).valid?
      end.first
    end

    private

    attr_reader :input, :numbers, :range_size

    def real_input
      @input ||= File.read("aoc/year2020/day9.txt")
    end
  end

  class Part2 < Part1
    def solution
      invalid_number = super
      combo_size = 2

      while combo_size < numbers.size
        countigious_set_index = numbers.each_with_index.find do |number, index|
          ValidNumber.new(
            invalid_number,
            ValidityRange.new(
              numbers: numbers,
              index: index,
              range_size: combo_size,
              combo_size: combo_size,
              preamble: false
            )
          ).valid?
        end

        if countigious_set_index
          index = countigious_set_index[1]
          return numbers[index - combo_size..index - 1].minmax.sum
        end

        combo_size += 1
      end
    end
  end
end

RSpec.describe "Day 9" do
  let(:input) {
    <<~INPUT
35
20
15
25
47
40
62
55
65
95
102
117
150
182
127
219
299
277
309
576
    INPUT
  }

  describe AoC::Year2020::Day9::Part1 do
    let(:instance) { described_class.new(input, range_size: 5) }

    describe "#solution" do
      subject { instance.solution }

      it { is_expected.to be(127) }
    end
  end

  describe AoC::Year2020::Day9::Part2 do
    let(:instance) { described_class.new(input, range_size: 5) }

    describe "#solution" do
      subject { instance.solution }

      it { is_expected.to be(62) }
    end
  end
end
