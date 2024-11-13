#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

RANDOM_NUMBER=$(( ( RANDOM % 1000 ) + 1 ))

echo "Enter your username:"
read USERNAME 

QUERY=$($PSQL "SELECT * FROM players WHERE username = '$USERNAME';")
if [[ $QUERY ]]
then
 IFS="|" read -r username games_played best_game <<< "$QUERY"
 echo "Welcome back, $username! You have played $games_played games, and your best game took $best_game guesses."
else
 echo "Welcome, $USERNAME! It looks like this is your first time here."
fi

GUESS_COUNT=0

echo "Guess the secret number between 1 and 1000:"
read USERGUESS

echo $RANDOM_NUMBER
while true; do
  ((GUESS_COUNT++))
  if [[ ! "$USERGUESS" =~ ^-?[0-9]+$ ]]; then
    echo "That is not an integer, guess again:"
  
  elif [[ "$USERGUESS" -ge 1 ]] && [[ "$USERGUESS" -le 1000 ]]; then
    if [[ "$USERGUESS" -lt "$RANDOM_NUMBER" ]]; then
      echo "It's higher than that, guess again:"
    elif [[ "$USERGUESS" -gt "$RANDOM_NUMBER" ]]; then
      echo "It's lower than that, guess again:"
    else
      break
    fi
  else
    echo "Please enter a number between 1 and 1000, guess again:"
  fi
  read USERGUESS
done

if [[ $QUERY ]]
then
  if [[ $best_game -ge $GUESS_COUNT ]]
  then 
    best_game=$GUESS_COUNT
  fi

  UPDATE=$($PSQL "UPDATE players
                  SET games_played = (games_played + 1), best_game = $best_game
                  WHERE username = '$USERNAME';")
    
else
  INSERT=$($PSQL "INSERT INTO players(username, games_played, best_game) VALUES('$USERNAME',1,$GUESS_COUNT)")
fi

echo "You guessed it in $GUESS_COUNT tries. The secret number was $RANDOM_NUMBER. Nice job!"