#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~ Salon Appointment Scheduler ~~~\n"

MAIN_MENU(){
  echo -e "Services:\n"
  SERVICES=$($PSQL "SELECT service_id,name FROM services ORDER BY service_id;")
  echo "$SERVICES" | while read SERVICE_ID BAR SERVICE_NAME
  do
    echo "$SERVICE_ID) $SERVICE_NAME"
  done
  #select a service
  echo "Please select a service number:"
  read SERVICE_ID_SELECTED
  SERVICE_ID_RESULT=$($PSQL "SELECT service_id FROM services WHERE service_id=$SERVICE_ID_SELECTED;")
  #if the service doesn't exist get a better one
  if [[ -z $SERVICE_ID_RESULT ]]
  then
    echo -e "\nNo such service"
    MAIN_MENU
  else
  #if it does exist get the phone number
    echo -e "\nPlease enter your phone number:"
    read CUSTOMER_PHONE
    CUSTOMER_NAME="$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE';")"
    #if the phone number doesn't already exist get a new name for account
    if [[ -z $CUSTOMER_NAME ]]
    then
      echo -e "\nNew Customer"
      echo -e "\nPlease enter your name:"
      read CUSTOMER_NAME
      CUSTOMER_NAME_RESULT="$($PSQL "INSERT INTO customers(phone,name) VALUES('$CUSTOMER_PHONE','$CUSTOMER_NAME');")"
    else
    #if account does exist say so
      echo -e "\nWelcome $CUSTOMER_NAME"
    fi
    #now that account data has been set up get an appointment time
    echo -e "\nPlease enter a time for your appointment"
    read SERVICE_TIME
    #Enter apt into the DB
    #get customer id
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE';")
    APT_RESULT="$($PSQL "INSERT INTO appointments(customer_id,service_id,time) VALUES($CUSTOMER_ID,$SERVICE_ID_SELECTED,'$SERVICE_TIME');")"
    #Thank the customer for coming with the sandard message
    #get service name
    SERVICE_NAME="$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED;")"
    echo -e "\nI have put you down for a $(echo $SERVICE_NAME | sed -r 's/^ *| *$//g') at $SERVICE_TIME, $(echo $CUSTOMER_NAME | sed -r 's/^ *| *$//g')."
  fi
}

MAIN_MENU
