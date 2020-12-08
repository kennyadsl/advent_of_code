module AoC::Year2020::Day8
  class Instruction
    attr_reader :name, :value, :program_state

    def initialize(name, value, program_state)
      @name = name
      @value = value.to_i
      @program_state = program_state
    end

    def run
      send(name)
    end

    private

    def nop
      program_state.jump
    end

    def jmp
      program_state.jump(steps: value)
    end

    def acc
      program_state.accumulate(value: value)
      program_state.jump
    end
  end

  class Program
    LOOP_STATE = 0
    EXIT_STATE = 1

    attr_reader :instructions
    attr_accessor :acc, :executed_instructions, :current_instruction_index, :swap_index

    def initialize(instructions:)
      @instructions = instructions

      @acc = 0
      @executed_instructions = []
      @current_instruction_index = 0
    end

    def run
      while program_not_ended?
        return LOOP_STATE if starting_loop?
        execute_current_instruction
      end

      EXIT_STATE
    end

    def jump(steps: 1)
      self.current_instruction_index += steps
    end

    def accumulate(value: 0)
      self.acc += value
    end

    private

    def program_not_ended?
      current_instruction_index < instructions.length
    end

    def starting_loop?
      executed_instructions.include? current_instruction_index
    end

    def execute_current_instruction
      mark_instruction_index_as_executed

      instruction = current_instruction
      instruction.run
    end

    def current_instruction
      name, value = instructions[current_instruction_index].split(' ')

      if swap_index && swap_index == current_instruction_index
        name = case name
        when 'nop' then 'jmp'
        when 'jmp' then 'nop'
        else name
        end
      end

      Instruction.new(name, value, self)
    end

    def mark_instruction_index_as_executed
      executed_instructions << current_instruction_index
    end
  end

  class Part1
    def initialize(input = real_input)
      @input = input
    end

    def solution
      program = Program.new(instructions: input.each_line.map(&:strip))
      program.run
      program.acc
    end

    private

    attr_reader :input

    def real_input
      @input ||= File.read("aoc/year2020/day8.txt")
    end
  end

  class Part2 < Part1
    def solution
      instructions = input.each_line.map(&:strip)

      fixed_programs = (0..instructions.length).each_with_object({}) do |instruction_index, memo|
        tentative_program = Program.new(instructions: instructions)
        tentative_program.swap_index = instruction_index

        memo[instruction_index] = tentative_program.acc if tentative_program.run == Program::EXIT_STATE
      end

      fixed_programs.first[1]
    end
  end
end

RSpec.describe "Day 8" do
  let(:input) {
    <<~INPUT
nop +0
acc +1
jmp +4
acc +3
jmp -3
acc -99
acc +1
jmp -4
acc +6
    INPUT
  }

  describe AoC::Year2020::Day8::Part1 do
    let(:instance) { described_class.new(input) }

    describe "#solution" do
      subject { instance.solution }

      it { is_expected.to be(5) }
    end
  end

  describe AoC::Year2020::Day8::Part2 do
    let(:instance) { described_class.new(input) }

    describe "#solution" do
      subject { instance.solution }

      it { is_expected.to be(8) }
    end
  end
end
