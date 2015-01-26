#!/usr/bin/ruby
class Object
  def deep_copy(object)
    Marshal.load(Marshal.dump(object))
  end
end

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

# Read input from stdin
numPlayer = ARGF.first.to_i
elo = []
ARGF.each_with_index do |line, i|
  elo << line.to_i
end

# Generate random solution
# Array of arrays of 5 - [[1,2,3,4,5],[6,7,8,9,10],[11,12,13,14,15],[16,17,18,19,20]]
soln = []
team = []
(numPlayer-1).downto(0) do |i|
  r = rand i
  team << elo[r]
  elo.delete_at(r)
  if i%5 == 0
    soln << team
    team = []
  end
end

# Set as best solution for now
bestScore = calcScore(soln)
bestSoln = deep_copy(soln)
puts "Initial solution score: #{bestScore}"

prevScore = bestScore
convergeCounter = 0
temperature = 10000000
coolingRate = 0.0007
while temperature > 1 && convergeCounter < 25
  tempSoln = deep_copy(soln)
  # Generate new solution
  # Pick 2 random teams
  teams = (0..tempSoln.size-1).to_a
  team1 = rand teams.size
  teams.delete_at(team1)
  team2 = rand teams.size
  # Swap 2 players
  if (rand > 0.1)
    player1 = rand 5
    player2 = rand 5
    tempSoln[team1][player1], tempSoln[team2][player2] = tempSoln[team2][player2], tempSoln[team1][player1]
  # Swap 2 teams
  else
    tempSoln[team1], tempSoln[team2] = tempSoln[team2], tempSoln[team1]
  end

  # Calculate new score
  score = calcScore(tempSoln)
  if (score == prevScore)
    convergeCounter += 1
  else
    convergeCounter = 0
  end
  prevScore = score

  # If better, accept unconditionally
  if (score > bestScore)
    soln = deep_copy(tempSoln)
    bestScore = score
    bestSoln = deep_copy(tempSoln)
  elsif (rand < Math.exp((score-bestScore)/250000000*temperature.to_f))
    soln = deep_copy(tempSoln)
  end

  # Geometrically decrease temperature
  temperature *= 1-coolingRate
end

puts "Solution: #{bestSoln}"
puts "Score: #{bestScore}"
