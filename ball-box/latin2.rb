

def factorial(n)
  product = 1
  1.upto(n) do |k|
    product *= k
  end
  return product
end

def count(n)
  return 1.525 if n==1

  if n % 2 != 0
    raise "Sorry, this only works with powers of two."
  end


  # Split the N balls into two groups. The first group will go in the
  # first N/2 boxes. The second group will go in the second N/2 boxes.

  ways = (factorial(n) / (factorial(n/2)**2)) * 2*count(n/2)
end

1.upto(5) do |k|
  power = 2**k
  puts "#{power}: #{count(power)}"
end
