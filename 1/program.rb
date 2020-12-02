expenses = []

File.readlines('1/input.txt').each do |line|
  expenses << line.to_i
end

# First part
puts expenses.combination(2).find { |a, b| a + b == 2020 }.inject(&:*)

# Second part
puts expenses.combination(3).find { |a, b, c| a + b + c == 2020 }.inject(&:*)
