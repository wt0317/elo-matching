#!/usr/bin/ruby
def calcTeamVar(team1, team2)
  sum1 = team1.inject(:+)
  sum2 = team2.inject(:+)
  (sum1-sum2)**2
end

def calcPlayerVar(team1, team2)
  arr = team1 + team2
  avg = arr.inject(:+).to_f/arr.size
  playerVar = []
  arr.each do |el|
    playerVar << (el-avg)**2
  end
  playerVar.inject(:+)
end

def calcScore(soln)
  variance = []
  soln.each_with_index do |team, i|
    if i%2 == 0
      variance << calcTeamVar(team, soln[i+1]) + calcPlayerVar(team, soln[i+1])
    end
  end
  avgVar = variance.inject(:+).to_f/variance.size
  (1+1000000000) / (1+avgVar)
end

numPlayer = ARGF.first.to_i
elo = []
ARGF.each_with_index do |line, i|
  elo << line.to_i
end

soln = []
team = []
(numPlayer-1).downto(0) do |i|
  r = rand(i)
  team << elo[r]
  elo.delete_at(r)
  if i%5 == 0
    soln << team
    team = []
  end
end

bestScore = calcScore(soln)
bestSoln = soln.dup

e = 100
k = 0

while k < 10000 && e < 250000000
  # Generate new solution
  teams = (0..soln.size-1).to_a
  team1 = rand teams.size
  teams.delete_at(team1)
  team2 = rand teams.size
  r = rand
  if (r > 0.25)
    player1 = rand 5
    player2 = rand 5
    soln[team1][player1], soln[team2][player2] = soln[team2][player2], soln[team1][player1]
  else
    soln[team1], soln[team2] = soln[team2], soln[team1]
  end

  # Calculate new score
  score = calcScore(soln)

  if (score > bestScore)
    bestScore = score
    bestSoln = soln.dup
  end

  k += 1
end

puts "Solution: #{bestSoln}"
puts "Score: #{bestScore}"
