#!/usr/bin/env ruby

# The ball-box problem is solved by considering a more general problem:
#
# Given N boxes labeled 1 through N, S balls labeled 1 through S, and N-S
# unlabled balls, how many ways can the balls be put into the boxes so that for
# each labeled ball, its label is different from the label of the box that it is
# in. In other words: there are N boxes and N balls, all with unique labels, but
# only S of the balls have the same label as one of the boxes.
# 
# Example:
#   N=4, S=2
#     Boxes: 1,2,3,4
#     Balls: 1,2,8,9
#   N=5, S=5
#     Boxes: 1,2,3,4,5
#     Balls: 1,2,3,4,5
#   N=3, S=0
#     Boxes: 1,2,3
#     Balls: 5,6,7
#
# If a solution count(n,s) to this problem is known, then the solution to the
# ball-box problem for N balls and boxes is count(N,N) (by definition).

def factorial(n)
  $factorial_memo ||= Hash.new
  if $factorial_memo[n]
    return $factorial_memo[n]
  end
  product = 1
  1.upto(n) do |k|
    product *= k
  end
  $factorial_memo[n] = product
  return product
end

def choose(n,k)
  if k > n
    return 0
  else
    return factorial(n)/(factorial(k)*factorial(n-k))
  end
end

# This is broken.
# def count(n, s)
#   if s == 0
#     return factorial(n)
#   end
# 
#   if n == 1
#     if s == 0
#       return 1
#     elsif s == 1
#       return 0
#     end
#   end
# 
#   sg = n/2
#   fg = n - sg
# 
#   result = 0
#   if s <= fg
#     0.upto(s) do |i|
#       result += choose(s,i) * count(fg, i) * choose(n-s, fg-i) * count(sg, 0)
#     end
#   else
#     0.upto(fg) do |sfg|
#       0.upto(s-fg) do |ssg|
#         next if sg - ssg > fg - sfg # check the count(3,3) case to see why this is necessary... but this is probably just a band-aid
#         # it's still wrong... i think it depends on whether the first one takes
#         # one same from the second or not...
# 
#         # result += choose(fg, sfg) * count(fg, sfg) * choose(sg-ssg, fg-sfg) * 
#         #   choose(s-fg, ssg) * count(sg, ssg) * choose(sg - ssg, sg - ssg)
#         x = choose(fg, sfg) * count(fg, sfg) * choose(sg-ssg, fg-sfg) *  # <---- it takes them from non-same sg when it COULD take some that are the same.
#           choose(s-fg, ssg) * count(sg, ssg) * choose(sg - ssg, sg - ssg)
#         if n == 7 && s == 7
#           # puts "Sfg: #{sfg}, Ssg: #{ssg}, X: #{x} (n: #{n} s: #{s})"
#         end
#         result += x
#       end
#     end
#   end
# 
#   return result
# end

def recursive_count(n, s)
  $count_memo ||= Hash.new

  if s == 0
    return factorial(n)
  end

  if n == 1
    if s == 0
      return 1
    elsif s == 1
      return 0
    end
  end

  if $count_memo[[n,s]]
    return $count_memo[[n,s]]
  end

  sg = 1
  fg = n - sg

  result = 0
  if s <= fg
    0.upto(s) do |i|
      result += choose(s,i) * count2(fg, i) * choose(n-s, fg-i) * count2(sg, 0)
    end
  else
    result += count2(fg, fg-1) * count2(sg, 0) * fg
  end

  $count_memo[[n,s]] = result

  return result
end

1.upto(100) do |n|
  puts "#{n}: #{count2(n,n)}"
end
