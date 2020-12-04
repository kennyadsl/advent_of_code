module AoC::Year2020::Day2
  class RangePasswordPolicyChecker
    attr_reader :min, :max, :char, :password

    def initialize(min, max, char, password)
      @min = min
      @max = max
      @char = char
      @password = password
    end

    def call
      valid?
    end

    private

    def valid?
      char_occurrences.between? min, max
    end

    def char_occurrences
      password.scan(/(?=#{char})/).count
    end
  end

  class PositionPasswordPolicyChecker
    attr_reader :position_1, :position_2, :char, :password

    def initialize(position_1, position_2, char, password)
      @position_1 = position_1 - 1
      @position_2 = position_2 - 1
      @char = char
      @password = password
    end

    def call
      valid?
    end

    private

    def valid?
      [
        password[position_1],
        password[position_2]
      ].tally[char] == 1
    end
  end

  class Part1
    def initialize(input = real_input)
      @input = input
    end

    def solution
      input.each_line.count do |password_policy|
        password_policy_checker.new(*password_policy_parser(password_policy)).call
      end
    end

    private

    def password_policy_checker
      RangePasswordPolicyChecker
    end

    def password_policy_parser(password_policy)
      range, char, password = password_policy.split(" ")
      min, max = range.split('-').map(&:to_i)
      char = char.split(':').first

      [
        min,
        max,
        char,
        password
      ]
    end

    attr_reader :input

    def real_input
      @input ||= File.read("aoc/year2020/day2.txt")
    end
  end

  class Part2 < Part1
    private

    def password_policy_checker
      PositionPasswordPolicyChecker
    end
  end
end

RSpec.describe "Day 2" do
  let(:input) {
    <<~INPUT
1-3 a: abcde
1-3 b: cdefg
2-9 c: ccccccccc
2-7 b: cbccccacc
    INPUT
  }

  describe AoC::Year2020::Day2::Part1 do
    let(:instance) { described_class.new(input) }

    describe "#solution" do
      subject { instance.solution }

      it 'detects the occurrences of valid passwords' do
        is_expected.to be(2)
      end
    end
  end

  describe AoC::Year2020::Day2::Part2 do
    let(:instance) { described_class.new(input) }

    describe "#solution" do
      subject { instance.solution }

      it 'detects the occurrences of valid passwords' do
        is_expected.to be(2)
      end
    end
  end
end
