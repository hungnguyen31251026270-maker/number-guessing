#!/bin/bash
# Number guessing game
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

SECRET_NUMBER=$(( RANDOM % 1000 + 1 ))

echo "Enter your username:"
read USERNAME

USER_INFO=$($PSQL "SELECT games_played, best_game FROM users WHERE username='$USERNAME'")

if [[ -z $USER_INFO ]]
then
  NEW_USER=true
  echo "Welcome, $USERNAME! It looks like this is your first time here."
else
  NEW_USER=false
  IFS="|" read GAMES_PLAYED BEST_GAME <<< "$USER_INFO"
  echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi
echo "Guess the secret number between 1 and 1000:"
GUESSES=0

while true
do
  read GUESS

  if [[ ! $GUESS =~ ^[0-9]+$ ]]
  then
    echo "That is not an integer, guess again:"
    continue
  fi

  GUESSES=$(( GUESSES + 1 ))

  if (( GUESS == SECRET_NUMBER ))
  then
    break
  elif (( GUESS > SECRET_NUMBER ))
  then
    echo "It's lower than that, guess again:"
  else
    echo "It's higher than that, guess again:"
  fi
done
if [[ $NEW_USER == true ]]
then
  SAVE_RESULT=$($PSQL "INSERT INTO users(username, games_played, best_game) VALUES('$USERNAME', 1, $GUESSES)")
else
  SAVE_RESULT=$($PSQL "UPDATE users SET games_played = games_played + 1, best_game = LEAST(best_game, $GUESSES) WHERE username='$USERNAME'")
fi

echo "You guessed it in $GUESSES tries. The secret number was $SECRET_NUMBER. Nice job!"