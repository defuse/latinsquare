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

# This solves the more general problem described above. 
# N is the number of boxes. S is the number of balls which have a label the same
# as one of the boxes.
def recursive_count(n, s)
  $count_memo ||= Hash.new

  # If none of the balls have the same label as one of the boxes, then we can
  # arrange them any way we want, since no matter how we do, the box's label
  # will not match the ball's label. There are n! ways to do that.
  if s == 0
    return factorial(n)
  end

  if n == 1
    if s == 0
      # If there is 1 box and 1 ball, and the ball isn't labled the same as the
      # box, then that ball can and must go in that box. So there is 1 way.
      return 1
    elsif s == 1
      # If there is 1 box and 1 ball, and the ball IS labled the same as the
      # box, then there are no possibilities, because putting that ball in the
      # box would be putting a ball into a box with the same label.
      return 0
    end
  end

  # The algorithm is exponential-time, but is well-suited for dynamic
  # programming as it only uses recursive_count(a,b) with a < n, b < s.
  if $count_memo[[n,s]]
    return $count_memo[[n,s]]
  end

  # Split the boxes into two groups. The first group will contain n-1 boxes and
  # the second group will contain just one box. We have the freedom to choose
  # which boxes go into which group, so we will put, if possible, all of the
  # boxes which have a same-numbered ball into the first group.
  # 
  # So, if s <= n-1, then all of the boxes with same-numbered balls go into the
  # first group. If s = n-1, then both groups are filled with boxes having
  # a same-numbered ball.
  #
  # Note: It may be possible to get a better running time by splitting the boxes
  # into more evenly-sized groups, but this is more complicated.

  sg = 1
  fg = n - sg

  # We count the number of solutions as follows:
  # If all of the boxes with same-numbered balls fit into the first group, we
  # add up all of the ways we can put:
  #
  #   0 same-numbered balls put into the first group
  #   1 same-numbered balls put into the first group
  #   2 same-numbered balls put into the first group
  #   ...
  #   S same-numbered balls put into the first group
  #
  # If all of the boxes with same-numbered balls do NOT fit into the first
  # group, then we recognize that there are zero possibilities when we give the
  # second group the ball which matches its box, so we add up all the
  # combinations we get by swapping the ith box's ball with the second group's
  # box's ball.

  result = 0
  if s <= fg
    0.upto(s) do |i|
      # i same-numbered balls into the first group
      result += choose(s,i) * # from S that could be the same, choose i
                choose(n-s, fg-i) * # choose the remaining fg-i from non-same balls
                recursive_count(fg, i) *
                recursive_count(sg, 0)
    end
  else
    result = recursive_count(fg, fg-1) * recursive_count(sg, 0) * fg
  end

  $count_memo[[n,s]] = result

  return result
end

1.upto(1000) do |n|
  puts "#{n}: #{recursive_count(n,n)}"
end
