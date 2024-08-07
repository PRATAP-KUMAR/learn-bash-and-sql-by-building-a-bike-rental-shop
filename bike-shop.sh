#!/bin/bash
PSQL="psql -X --username=admin --dbname=bikes --tuples-only -c"

echo -e "\n~~~~~ Bike Rental Shop ~~~~~\n"

MAIN_MENU() {
  if [[ $1 ]]; then
    echo -e "\n$1"
  fi

  echo "How may I help you"
  echo -e "\n1. Rent a bike\n2. Return a bike\n3. Exit"
  read MAIN_MENU_SELECTION
  case $MAIN_MENU_SELECTION in
  1) RENT_MENU ;;
  2) RETURN_MENU ;;
  3) EXIT ;;
  *) MAIN_MENU "Please enter a valid option." ;;
  esac
}

RENT_MENU() {
  # get available bikes
  AVAILABLE_BIKES=$($PSQL "select bike_id, type, size from bikes where available = true order by bike_id")
  echo $AVAILABLE_BIKES
  # if no bikes available
  if [[ -z $AVAILABLE_BIKES ]]; then
    # send to main menu
    MAIN_MENU "Sorry, we don't have any bikes available right now."
  else
    # display available bikes
    echo -e "\nHere are the bikes we have available:"
    echo "$AVAILABLE_BIKES" | while read BIKE_ID BIKE_TYPE BIKE_SIZE; do
      echo "$BIKE_ID) $BIKE_SIZE\" $BIKE_TYE Bike"
    done
    # ask for bike to rent
    echo -e "\nWhich one would you like to rent?"
    read BIKE_ID_TO_RENT
    # if input is not a number
    if [[ ! $BIKE_ID_TO_RENT =~ ^[0-9]+$ ]]; then
      # send to main menu
      MAIN_MENU "That is not a valid bike number."
    else
      # get bike availability
      BIKE_AVAILABILITY=$($PSQL "select available from bikes where bike_id = $BIKE_ID_TO_RENT AND available = true;")
      # if not available
      if [[ -z $BIKE_AVAILABILITY ]]; then
        # send to main menu
        MAIN_MENU "That bike is not available."
      else
        # get customer info
        echo -e "\nWhat's your phone number?"
        read PHONE_NUMBER
        CUSTOMER_NAME=$($PSQL "select name from customers where phone = '$PHONE_NUMBER';")
      fi
      # if customer doesn't exist
      if [[ -z $CUSTOMER_NAME ]]; then
        # get new customer name
        echo -e "\nWhat's your name?"
        read CUSTOMER_NAME
        # insert new customer
        INSERT_CUSTOMER_RESULT=$($PSQL "insert into customers(phone, name) values('$PHONE_NUMBER', '$CUSTOMER_NAME');")
      fi
    fi
  fi
}

RETURN_MENU() {
  echo "Rent Menu"
}

EXIT() {
  echo -e "\nThank you for stopping in.\n"
}

MAIN_MENU
