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
  # I'm too lazy to figure out how to implement choose properly for negative
  # arguments, but the only one we need is n=0,k=-1, which is zero.
  # There is a more complete definition here if you feel like implementing it:
  # http://mathworld.wolfram.com/BinomialCoefficient.html
  if n == 0 && k == -1
    return 0
  end

  if n < 0 || k < 0
    raise "ERROR: negative choose args."
  end

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
  # first group. If s = n, then both groups are filled with boxes having a
  # same-numbered ball.
  #
  # Note: It may be possible to get a better running time by splitting the boxes
  # into more evenly-sized groups, but this is more complicated.

  # sg is the number of boxes in the second group.
  sg = 1
  # fg is the number of boxes in the first group.
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
  #
  # The solution is quite a bit simpler when we realize that we can either put
  # the second group's box's ball in the second group or not. 
  #
  # If s=n:
  #   - We CAN NOT put the second group's box's ball in the second group.
  #   - There are n-1 other balls that can be put in the second group.
  # If s<n:
  #   - We CAN put the second group's box's ball in the second group.
  #   - If we do, it MUST be a ball matching one of the boxes in the first
  #     group, so there are S ways of doing it.

  result = 0
  if s < n
    result += recursive_count(n-1, s) + s * recursive_count(n-1, s-1)
  else
    result += (n-1) * recursive_count(n-1, n-2)
  end

  # Some intermediate stages of work:
  #result += [s,n-1].min*recursive_count(n-1, [s,n-1].min-1)
  #result += recursive_count(n-1, [s,n-1].min) * recursive_count(1, s-[s,n-1].min)
  # ([s,fg].min-1).upto([s,fg].min) do |i|
  #   # second group's box's pair is used as filling for group one
  #   result += choose([s,fg].min, i) * choose(n-1-[s,fg].min, fg-i-1) * recursive_count(fg, i) * recursive_count(sg, 0)
  #   # second group's box's pair is NOT used as filling for group one
  #   result += choose([s,fg].min, i) * choose(n-1-[s,fg].min, fg-i) * recursive_count(fg, i) * recursive_count(sg, s - [s,n-1].min)
  # end

  $count_memo[[n,s]] = result

  return result
end

# An iterative implementation can do it in O(N^2) space and O(N^3) time.
# This actually answers all O(N^2) problems up to count(n,s) so, amortized,
# it's more like O(N) on average.
def iterative_count(n, s)
  # Create an (N+1) x (S+1) table.
  table = Array.new( n+1 ) { Array.new( s+1 ) }

  # Base case S=0.
  0.upto(n) do |x|
    table[x][0] = factorial(x)
  end

  # Base case N=0.
  table[0][0] = 0
  table[0][1] = 0
  1.upto(s) { |x| table[0][x] = 'X' }
  # Base case N=1.
  table[1][0] = 1
  table[1][1] = 0
  2.upto(s) { |x| table[1][x] = 'X' }

  # 'Recursive' cases.
  1.upto(s) do |ss|
    2.upto(n) do |nn|
      if ss > nn
        table[nn][ss] = 'X'
      else
        if ss <= nn-1
          table[nn][ss] = table[nn-1][ss] + ss*table[nn-1][ss-1]
        else
          table[nn][ss] = (nn-1) * table[nn-1][nn-1-1] 
        end
      end
    end
  end

  # Print a table fror small inputs.
  if n <= 9
    puts "Going Down: S. Going Across: N"
    print "-" * 80 + "\n"
    table.transpose.each do |row|
      row.each do |col|
        print "%8s" % col
      end
      print "\n"
    end
    print "-" * 80 + "\n"
  end

  return table[n][s]
end

1.upto(100) do |i|
  puts iterative_count(i,i)
end
