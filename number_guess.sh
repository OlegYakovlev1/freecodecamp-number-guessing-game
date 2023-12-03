#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess --tuples-only -c"
GENERATED_NUMBER=$((1 + $RANDOM % 1000))
NUMBER_OF_GUESSES=0

echo "Enter your username:"
read USERNAME

USER_ID=$($PSQL "select user_id from users where username='$USERNAME'")
if [[ -z $USER_ID ]]
then
  INSERT_USER=$($PSQL "insert into users(username) values('$USERNAME')")
  USER_ID=$($PSQL "select user_id from users where username='$USERNAME'")
  echo "Welcome, $USERNAME! It looks like this is your first time here."
else
  GAMES_INFO=$($PSQL "select count(game_id), min(guesses) from games where user_id=$USER_ID")
  echo "$GAMES_INFO" | while read COUNT BAR GUESSES
  do
    echo "Welcome back, $USERNAME! You have played $COUNT games, and your best game took $GUESSES guesses."
  done
fi

EXIT() {
  INSERT_GAME=$($PSQL "insert into games(user_id, guesses, number) values($USER_ID, $NUMBER_OF_GUESSES, $GENERATED_NUMBER)")
  echo "You guessed it in $NUMBER_OF_GUESSES tries. The secret number was $GENERATED_NUMBER. Nice job!"
}

MAIN() {
  ((NUMBER_OF_GUESSES+=1))

  if [[ $USER_INPUT -eq $GENERATED_NUMBER ]]
  then
    EXIT
  else
    if [[ $1 != ?(-)+([0-9]) ]]
    then
      echo "That is not an integer, guess again:"
    elif [[ $USER_INPUT -lt $GENERATED_NUMBER ]];
    then
      echo "It's lower than that, guess again:"
    elif [[ $USER_INPUT -gt $GENERATED_NUMBER ]];
    then
      echo "It's higher than that, guess again:"
    fi

    read USER_INPUT
    MAIN $USER_INPUT
  fi
}

echo "Guess the secret number between 1 and 1000:"
read USER_INPUT
MAIN $USER_INPUT