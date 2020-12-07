module AoC::Year2020::Day7
  class BagColorRules
    attr_reader :name, :rules

    def initialize(name, rules)
      @name = name.sub(' bags', '')
      @rules = rules.split(', ').each_with_object({}) do |rule, memo|
        rule_text = rule.sub(/ bag(s?)(.?)(\n?)/, '')

        if rule_text == 'no other'
          memo[rule_text] = 0
        else
          rule_parts = rule_text.match(/(?<number>\d+) (?<color>\b\w+ \w+$)/)
          memo[rule_parts[:color]] = rule_parts[:number].to_i
        end
      end
    end

    def can_contain?(color)
      rules.key? color
    end

    def bags_inside?
      rules.any?
    end
  end

  class BagRegulations
    attr_reader :bag_rules

    def initialize(input)
      @input = input

      @bag_rules = input.each_line.map { |rule| BagColorRules.new(*rule.split(' contain ')) }
    end

    def outer_containers_for(color)
      direct_containers = bag_rules.select { |rule| rule.can_contain? color }
      return (direct_containers + direct_containers.map { |rule| outer_containers_for(rule.name) }).flatten.uniq
    end

    def inner_bags(color)
      current_color_rule = bag_rules.find { |rule| rule.name == color }
      return [] if !current_color_rule || !current_color_rule.bags_inside?

      current_color_rule.rules.map do |color, number|
        [color] * number + inner_bags(color) * number
      end.flatten
    end
  end

  class Part1
    attr_reader :bag_regulations
    def initialize(input = real_input)
      @input = input
      @bag_regulations = BagRegulations.new(input)
    end

    def solution
      bag_regulations.outer_containers_for('shiny gold').count
    end

    private

    attr_reader :input

    def real_input
      @input ||= File.read("aoc/year2020/day7.txt")
    end
  end

  class Part2 < Part1
    def solution
      bag_regulations.inner_bags('shiny gold').count
    end
  end
end

RSpec.describe "Day 7" do
  let(:input) {
    <<~INPUT
light red bags contain 1 bright white bag, 2 muted yellow bags.
dark orange bags contain 3 bright white bags, 4 muted yellow bags.
bright white bags contain 1 shiny gold bag.
muted yellow bags contain 2 shiny gold bags, 9 faded blue bags.
shiny gold bags contain 1 dark olive bag, 2 vibrant plum bags.
dark olive bags contain 3 faded blue bags, 4 dotted black bags.
vibrant plum bags contain 5 faded blue bags, 6 dotted black bags.
faded blue bags contain no other bags.
dotted black bags contain no other bags.
    INPUT
  }

  let(:input2) {
    <<~INPUT
shiny gold bags contain 2 dark red bags.
dark red bags contain 2 dark orange bags.
dark orange bags contain 2 dark yellow bags.
dark yellow bags contain 2 dark green bags.
dark green bags contain 2 dark blue bags.
dark blue bags contain 2 dark violet bags.
dark violet bags contain no other bags.
    INPUT
  }

  describe AoC::Year2020::Day7::Part1 do
    let(:instance) { described_class.new(input) }

    describe "#solution" do
      subject { instance.solution }

      it { is_expected.to be(4) }
    end
  end

  describe AoC::Year2020::Day7::Part2 do
    let(:instance) { described_class.new(input) }

    describe "#solution" do
      subject { instance.solution }

      it { is_expected.to be(32) }

      context "with another input" do
        let(:instance) { described_class.new(input2) }

        it { is_expected.to be(126) }
      end
    end
  end
end
