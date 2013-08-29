#!/usr/bin/env ruby
#
# There are N boxes numbered 1 to N. There are N balls numbered 1 to N.
# Balls can be put into boxes. How many ways can you put each ball in a box so
# that each ball's number is *different* from the number of the box it's in?
#
# Example for N=3:
#    
# RIGHT:
#
#     |   |   |   |
#     | 3 | 2 | 1 |
#     |#1#|#2#|#3#|
#
# WRONG:
#
#     | * |   |   |
#     | 1 | 3 | 2 |
#     |#1#|#2#|#3#|

last = nil
1.upto(20) do |n|

  boxes = (1..n).to_a
  balls = (1..n).to_a

  count = 0
  total = 0

  balls.permutation do |bperm|
    add = 1
    0.upto(n-1) do |i|
      if bperm[i] == boxes[i]
        add = 0
        break
      end
    end
    count += add
    total += 1
  end

  puts "Count for N=#{n}: #{count} (of #{total})"

  last = count
end
