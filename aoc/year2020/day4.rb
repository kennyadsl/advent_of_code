require 'active_support'
require 'active_model/validator'
require 'active_model/naming'
require 'active_model/callbacks'
require 'active_model/translation'
require 'active_model/errors'
require 'active_model/validations'

module AoC::Year2020::Day4
  class Part1
    def initialize(input = real_input)
      @input = input
    end

    def solution
      passports.count(&:valid?)
    end

    private

    def passports
      input.split("\n\n").map do |raw_passport_data|
        passport_data = raw_passport_data.split(/\s/).map { |string| string.split(':') }.to_h.transform_keys! { |key| key.to_sym }
        passport_class.new(**passport_data)
      end
    end

    def passport_class
      Passport
    end

    attr_reader :input

    def real_input
      @input ||= File.read("aoc/year2020/day4.txt")
    end
  end

  class Passport
    # byr (Birth Year)
    # iyr (Issue Year)
    # eyr (Expiration Year)
    # hgt (Height)
    # hcl (Hair Color)
    # ecl (Eye Color)
    # pid (Passport ID)
    # cid (Country ID)
    attr_reader :byr, :iyr, :eyr, :hgt, :hcl, :ecl, :pid, :cid

    include ActiveModel::Validations
    validates_presence_of :byr, :iyr, :eyr, :hgt, :hcl, :ecl, :pid

    def initialize(byr: nil, iyr: nil, eyr: nil, hgt: nil, hcl: nil, ecl: nil, pid: nil, cid: nil)
      @byr = byr
      @iyr = iyr
      @eyr = eyr
      @hgt = hgt
      @hcl = hcl
      @ecl = ecl
      @pid = pid
      @cid = cid
    end
  end

  class StrictPassport < Passport
    validates :byr, numericality: { only_integer: true, greater_than_or_equal_to: 1920, less_than_or_equal_to: 2002 }
    validates :iyr, numericality: { only_integer: true, greater_than_or_equal_to: 2010, less_than_or_equal_to: 2020 }
    validates :eyr, numericality: { only_integer: true, greater_than_or_equal_to: 2020, less_than_or_equal_to: 2030 }
    validates_each :hgt do |record, attr, value|
      unless value.nil?
        is_cm = value.delete!('cm')
        is_in = value.delete!('in')
        value = value.to_i

        valid_cm = is_cm && value >= 150 && value <= 193
        valid_in = is_in && value >= 59 && value <= 76
      end

      valid_height = valid_cm || valid_in

      if value.nil? || !valid_height
        record.errors.add(attr, 'is not valid')
      end
    end
    validates :hcl, format: { with: /\A#[0-9a-f]{6}\z/ }
    validates :ecl, inclusion: { in: %w(amb blu brn gry grn hzl oth) }
    validates :pid, format: { with: /\A\d{9}\z/ }
  end

  class Part2 < Part1
    def passport_class
      StrictPassport
    end
  end
end

RSpec.describe "Day 4" do
  describe AoC::Year2020::Day4::Part1 do
    let(:input) {
    <<~INPUT
ecl:gry pid:860033327 eyr:2020 hcl:#fffffd
byr:1937 iyr:2017 cid:147 hgt:183cm

iyr:2013 ecl:amb cid:350 eyr:2023 pid:028048884
hcl:#cfa07d byr:1929

hcl:#ae17e1 iyr:2013
eyr:2024
ecl:brn pid:760753108 byr:1931
hgt:179cm

hcl:#cfa07d eyr:2025 pid:166559648
iyr:2011 ecl:brn hgt:59in
    INPUT
    }

    let(:instance) { described_class.new(input) }

    describe "#solution" do
      subject { instance.solution }

      it 'detects all the valid passports' do
        is_expected.to be 2
      end
    end
  end

  describe AoC::Year2020::Day4::Part2 do
    let(:instance) { described_class.new(input) }
    let(:input) {
    <<~INPUT
eyr:1972 cid:100
hcl:#18171d ecl:amb hgt:170 pid:186cm iyr:2018 byr:1926

iyr:2019
hcl:#602927 eyr:1967 hgt:170cm
ecl:grn pid:012533040 byr:1946

hcl:dab227 iyr:2012
ecl:brn hgt:182cm pid:021572410 eyr:2020 byr:1992 cid:277

hgt:59cm ecl:zzz
eyr:2038 hcl:74454a iyr:2023
pid:3556412378 byr:2007

pid:087499704 hgt:74in ecl:grn iyr:2012 eyr:2030 byr:1980
hcl:#623a2f

eyr:2029 ecl:blu cid:129 byr:1989
iyr:2014 pid:896056539 hcl:#a97842 hgt:165cm

hcl:#888785
hgt:164cm byr:2001 iyr:2015 cid:88
pid:545766238 ecl:hzl
eyr:2022

iyr:2010 hgt:158cm hcl:#b6652a ecl:blu byr:1944 eyr:2021 pid:093154719
    INPUT
    }

    describe "#solution" do
      subject { instance.solution }

      it 'detects all the valid passports' do
        is_expected.to be 4
      end
    end
  end
end
