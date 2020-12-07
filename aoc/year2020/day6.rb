module AoC::Year2020::Day6
  FORM_QUESTIONS = 'a'..'z'

  class CustomsFormDataRetrieverAny
    def initialize(raw_data)
      @raw_data = raw_data
    end

    FORM_QUESTIONS.each do |answer|
      define_method(answer) do
        yes?(answer.to_s)
      end
    end

    private

    attr_reader :raw_data

    def yes?(answer)
      raw_data.include? answer
    end
  end

  class CustomsFormDataRetrieverAll < CustomsFormDataRetrieverAny
    def yes?(answer)
      raw_data.each_line.all? { |group_item| group_item.include? answer }
    end
  end

  class Group
    attr_reader :data_retriever

    def initialize(data_retriever:)
      @data_retriever = data_retriever
    end

    FORM_QUESTIONS.each do |question|
      define_method(question) do
        data_retriever.send(question)
      end
    end

    def counts
      FORM_QUESTIONS.sum do |question|
        send(question) ? 1 : 0
      end
    end
  end

  class Part1
    def initialize(input = real_input)
      @input = input
    end

    def solution
      input.split("\n\n").sum do |raw_customs_form|
        Group.new(
          data_retriever: custom_form_data_retriever_class.new(raw_customs_form)
        ).counts
      end
    end

    private

    def custom_form_data_retriever_class
      CustomsFormDataRetrieverAny
    end

    attr_reader :input

    def real_input
      @input ||= File.read("aoc/year2020/day6.txt")
    end
  end

  class Part2 < Part1
    private

    def custom_form_data_retriever_class
      CustomsFormDataRetrieverAll
    end
  end
end

RSpec.describe "Day 6" do
  let(:input) {
    <<~INPUT
abc

a
b
c

ab
ac

a
a
a
a

b
    INPUT
  }

  describe AoC::Year2020::Day6::CustomsFormDataRetrieverAny do
    it 'correctly retrieve values' do
      test_input_results = input.split("\n\n").map do |raw_customs_form|
        described_class.new(raw_customs_form)
      end

      expect(test_input_results[0].a).to be true
      expect(test_input_results[0].b).to be true
      expect(test_input_results[0].c).to be true
      expect(test_input_results[0].x).to be false
      expect(test_input_results[0].y).to be false
      expect(test_input_results[0].z).to be false

      expect(test_input_results[1].a).to be true
      expect(test_input_results[1].b).to be true
      expect(test_input_results[1].c).to be true
      expect(test_input_results[1].x).to be false
      expect(test_input_results[1].y).to be false
      expect(test_input_results[1].z).to be false

      expect(test_input_results[2].a).to be true
      expect(test_input_results[2].b).to be true
      expect(test_input_results[2].c).to be true
      expect(test_input_results[2].x).to be false
      expect(test_input_results[2].y).to be false
      expect(test_input_results[2].z).to be false

      expect(test_input_results[3].a).to be true
      expect(test_input_results[3].b).to be false
      expect(test_input_results[3].c).to be false
      expect(test_input_results[3].x).to be false
      expect(test_input_results[3].y).to be false
      expect(test_input_results[3].z).to be false

      expect(test_input_results[4].a).to be false
      expect(test_input_results[4].b).to be true
      expect(test_input_results[4].c).to be false
      expect(test_input_results[4].x).to be false
      expect(test_input_results[4].y).to be false
      expect(test_input_results[4].z).to be false
    end
  end

  describe AoC::Year2020::Day6::CustomsFormDataRetrieverAll do
    it 'correctly retrieve values' do
      test_input_results = input.split("\n\n").map do |raw_customs_form|
        described_class.new(raw_customs_form)
      end

      expect(test_input_results[0].a).to be true
      expect(test_input_results[0].b).to be true
      expect(test_input_results[0].c).to be true
      expect(test_input_results[0].x).to be false
      expect(test_input_results[0].y).to be false
      expect(test_input_results[0].z).to be false

      expect(test_input_results[1].a).to be false
      expect(test_input_results[1].b).to be false
      expect(test_input_results[1].c).to be false
      expect(test_input_results[1].x).to be false
      expect(test_input_results[1].y).to be false
      expect(test_input_results[1].z).to be false

      expect(test_input_results[2].a).to be true
      expect(test_input_results[2].b).to be false
      expect(test_input_results[2].c).to be false
      expect(test_input_results[2].x).to be false
      expect(test_input_results[2].y).to be false
      expect(test_input_results[2].z).to be false

      expect(test_input_results[3].a).to be true
      expect(test_input_results[3].b).to be false
      expect(test_input_results[3].c).to be false
      expect(test_input_results[3].x).to be false
      expect(test_input_results[3].y).to be false
      expect(test_input_results[3].z).to be false

      expect(test_input_results[4].a).to be false
      expect(test_input_results[4].b).to be true
      expect(test_input_results[4].c).to be false
      expect(test_input_results[4].x).to be false
      expect(test_input_results[4].y).to be false
      expect(test_input_results[4].z).to be false
    end
  end

  describe AoC::Year2020::Day6::Part1 do
    let(:instance) { described_class.new(input) }

    describe "#solution" do
      subject { instance.solution }

      it { is_expected.to eq 11 }
    end
  end

  describe AoC::Year2020::Day6::Part2 do
    let(:instance) { described_class.new(input) }

    describe "#solution" do
      subject { instance.solution }

      it { is_expected.to eq 6 }
    end
  end
end
