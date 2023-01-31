#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

echo "Enter your username:"
read NAME

# query db for username
USER_ID=$($PSQL "SELECT user_id FROM users WHERE name='$NAME'")

# check if user played before
if [[ -z $USER_ID ]]
then
  # new player
  echo "Welcome, $NAME! It looks like this is your first time here."
else
  # played before
  GAMES_PLAYED=$($PSQL "SELECT games FROM users WHERE name='$NAME'")
  SCORE=$($PSQL "SELECT score FROM users WHERE name='$NAME'")
  echo "Welcome back, $NAME! You have played $GAMES_PLAYED games, and your best game took $SCORE guesses."
fi

# generate random number 1-1000
NUMBER=$(($RANDOM%1000 + 1))
GUESS=0
TRIES=0

echo "Guess the secret number between 1 and 1000:"
while [[ $GUESS != $NUMBER ]]
do
  TRIES=$(($TRIES+1))
  read GUESS
  if [[ $GUESS =~ ^[0-9]+$ ]]
  then
    if [[ $GUESS == $NUMBER ]]
    then
      # insert values in db
      if [[ -z $USER_ID ]]
      then
        # new user
        GAMES=0
        BEST_SCORE=$TRIES
        INSERT=$($PSQL "INSERT INTO users(name, games, score) VALUES('$NAME', $(($GAMES+1)), $BEST_SCORE)")
      else
        # played before
        GAMES=$($PSQL "SELECT games FROM users WHERE user_id=$USER_ID")
        BEST_SCORE=$($PSQL "SELECT score FROM users WHERE user_id=$USER_ID")
        if [[ $TRIES -lt $BEST_SCORE ]]
        then
          BEST_SCORE=$TRIES
        fi
        UPDATE=$($PSQL "UPDATE users SET score=$BEST_SCORE, games=$(($GAMES+1)) WHERE user_id=$USER_ID")
      fi
      echo "You guessed it in $TRIES tries. The secret number was $NUMBER. Nice job!"
    else
      if [[ $GUESS < $NUMBER ]]
      then
        echo "It's higher than that, guess again:"
      else
        echo "It's lower than that, guess again:"
      fi
    fi
  else
    echo "That is not an integer, guess again:"
  fi
done
