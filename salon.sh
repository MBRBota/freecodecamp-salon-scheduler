#!/bin/bash
PSQL="psql -X --username=freecodecamp --dbname=salon -t -c"
#sed -r 's/(\w)/\l\1/'

echo -e "\n ~~~~~ MY SALON ~~~~~ \n"

MAIN_MENU(){
  if [[ $1 ]]
  then
    echo -e "\n$1"
  else
    echo -e "Welcome to my salon, how may I help you?\n"
  fi

  SERVICES=$($PSQL "SELECT * FROM services")
  echo "$SERVICES" | while read SERVICE_ID BAR SERVICE_NAME
  do
    echo "$SERVICE_ID) $SERVICE_NAME"
  done

  read SERVICE_ID_SELECTED
  if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
  then
    MAIN_MENU "Service not found. Please select a valid service."
  else
    SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED" | sed -r 's/(\w)/\l\1/')
    if [[ -z $SERVICE_NAME ]]
    then
      MAIN_MENU "Service not found. Please elect a valid service."
    else
      SERVICE_MENU
    fi
  fi
}

SERVICE_MENU(){
  echo -e "\nWhat is your phone number?"
  read CUSTOMER_PHONE
  if [[ -z $CUSTOMER_PHONE ]]
  then
    MAIN_MENU "Phone number invalid. Please try again with a valid phone number."
  fi
  CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")
  if [[ -z $CUSTOMER_NAME ]]
  then
    echo -e "\nYou appear to be a new customer! What is your name?"
    read CUSTOMER_NAME
    if [[ -z $CUSTOMER_NAME ]]
    then
      MAIN_MENU "Name invalid. Please try again."
    else
      CUSTOMER_INSERT=$($PSQL "INSERT INTO customers (phone, name) VALUES ('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
      APP_INSERT
    fi
  else
    APP_INSERT
  fi
}

APP_INSERT(){
  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
  echo -e "\nWhat time would you like your $(echo $SERVICE_NAME | sed -r 's/^ *| *$//g'), $(echo $CUSTOMER_NAME | sed -r 's/^ *| *$//g')?"
  read SERVICE_TIME
  if [[ -z $SERVICE_TIME ]]
  then
    MAIN_MENU "Appointment time invalid. Please try again with a valid appointment time."
  else
    APPOINTMENT_INSERT=$($PSQL "INSERT INTO appointments (customer_id, service_id, time) VALUES ($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
    echo -e "\nI have put you down for a $(echo $SERVICE_NAME | sed -r 's/^ *| *$//g') at $SERVICE_TIME, $(echo $CUSTOMER_NAME | sed -r 's/^ *| *$//g')."
  fi
}

MAIN_MENU
