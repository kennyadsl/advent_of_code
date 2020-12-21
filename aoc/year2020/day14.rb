module AoC::Year2020::Day14
  class Instruction
    attr_reader :mask, :write_values

    def initialize(mask, write_values)
      @mask = mask
      @write_values = write_values
    end

    def to_s
      "#{mask}, #{write_values}"
    end

    def self.from_input(input)
      mask = input.shift
      write_values = input.map { |write_value_input| WriteValue.from_input(write_value_input) }

      new(mask, write_values)
    end
  end

  class WriteValue
    attr_reader :position, :value

    def initialize(position, value)
      @position = position.to_i
      @value = value.to_i
    end

    def to_s
      "mem[#{position}] = #{value}"
    end

    def self.from_input(input)
      values_from_input = input.match(/(mem\[)(?<position>\d+)(\]) = (?<value>\d+)/)
      new(values_from_input[:position], values_from_input[:value])
    end
  end

  class MemoryValue
    attr_reader :mask, :write_value
    attr_accessor :left

    def initialize(mask, write_value, left = nil)
      @mask = mask
      @write_value = write_value
      @left = left || init_value
    end

    def call
      apply_mask(write_value.value.to_s(2))
      apply_mask(mask)

      self
    end

    def left_to_s
      left.to_i(2)
    end

    private

    def apply_mask(current_mask)
      current_mask.reverse.each_char.with_index do |char, index|
        left[left.length - index - 1] = char if ["0", "1"].include? char
      end
    end

    def init_value
      "0"*mask.length
    end
  end

  class FloatingMemoryValue
    attr_reader :mask, :write_value
    attr_accessor :left

    def initialize(mask, write_value)
      @mask = mask
      @write_value = write_value
      @left = init_value
    end

    def call
      apply_mask(write_value.position.to_s(2))
      apply_floating_mask(mask)

      self
    end

    def left_to_s
      left.to_i(2)
    end

    private

    def apply_mask(current_mask)
      current_mask.reverse.each_char.with_index do |char, index|
        left[left.length - index - 1] = char if ["0", "1"].include? char
      end
    end

    def apply_floating_mask(current_mask)
      current_mask.reverse.each_char.with_index do |char, index|
        left[left.length - index - 1] = char unless char == '0'
      end
    end

    def init_value
      "0"*mask.length
    end
  end

  class MemoryValueOverride
    attr_reader :program, :instruction, :write_value

    def initialize(program, instruction, write_value)
      @program = program
      @instruction = instruction
      @write_value = write_value
    end

    def call
      program[write_value.position] = MemoryValue.new(instruction.mask, write_value).call
    end
  end

  class MemoryAddressDecorerOverride < MemoryValueOverride
    def call
      floating_value = FloatingMemoryValue.new(instruction.mask, write_value).call
      number_of_variables = floating_value.left.count('X')

      combinations = 2**number_of_variables

      (0..combinations-1).each.with_index do |combination, index|
        combination_value = combination.to_s(2).reverse.each_char.to_a
        combination_memory_address = floating_value.left.dup.reverse

        while (current_value = combination_value.shift) != nil
          combination_memory_address.sub!("X", current_value.to_s)
        end

        combination_memory_address.reverse!
        combination_memory_address.gsub!("X", "0")

        memory_address = combination_memory_address.to_i(2)
        memory_value = floating_value.write_value.value.to_s(2)

        program[memory_address] = MemoryValue.new(nil, nil, memory_value)
      end
    end
  end

  class Part1
    def initialize(input = real_input)
      @input = input.split(/mask = /).drop(1)
    end

    def solution
      instructions = input.map { |x| Instruction.from_input(x.split("\n")) }

      init_value = "000000000000000000000000000000000000"

      program = {}

      instructions.each do |instruction|
        instruction.write_values.each do |write_value|
          value_override_class.new(program, instruction, write_value).call
        end
      end

      program.values.sum(&:left_to_s)
    end

    private

    def value_override_class
      MemoryValueOverride
    end

    attr_reader :input

    def real_input
      @input ||= File.read("aoc/year2020/day14.txt")
    end
  end

  class Part2 < Part1
    def value_override_class
      MemoryAddressDecorerOverride
    end
  end
end

RSpec.describe "Day 14" do
  let(:input) {
    <<~INPUT
mask = XXXXXXXXXXXXXXXXXXXXXXXXXXXXX1XXXX0X
mem[8] = 11
mem[7] = 101
mem[8] = 0
    INPUT
  }

  describe AoC::Year2020::Day14::Part1 do
    let(:instance) { described_class.new(input) }

    describe "#solution" do
      subject { instance.solution }

      it { is_expected.to be(165) }
    end
  end

  describe AoC::Year2020::Day14::Part2 do
    let(:input) {
      <<~INPUT
mask = 000000000000000000000000000000X1001X
mem[42] = 100
mask = 00000000000000000000000000000000X0XX
mem[26] = 1
      INPUT
    }
    let(:instance) { described_class.new(input) }

    describe "#solution" do
      subject { instance.solution }

      it { is_expected.to be(208) }
    end
  end
end
