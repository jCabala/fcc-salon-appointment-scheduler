#! /bin/bash
PSQL="psql --username=freecodecamp --dbname=salon --tuples-only -c"

MAIN_MENU() {
  if [[ $1 ]]
  then
    echo -e "\n$1\n"
  fi

  # Printing the list of services
  SERVICES=$($PSQL "SELECT * FROM services ORDER BY service_id")

  echo "$SERVICES" | while read SERVICE_ID BAR SERVICE_NAME
  do
    echo "$SERVICE_ID) $SERVICE_NAME"
  done

  # Getting a service id and making sure it's valid
  read SERVICE_ID_SELECTED
  
  if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
  then
    # Invalid Id: not a number
    echo $SERVICE_ID_SELECTED
    MAIN_MENU "I could not find that service. What would you like today?"
  else 
    SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id='$SERVICE_ID_SELECTED'")

    if [[ -z $SERVICE_NAME ]]
    then
      # Invalid Id: not in the list
      MAIN_MENU "I could not find that service. What would you like today?"
    else
      # Valid id
      # Geting customer data or registering a new customer
      echo -e "\nWhat's your phone number?"
      read CUSTOMER_PHONE

      # Checking if customer already registered
      CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")

      if [[ -z $CUSTOMER_NAME ]]
      then
        # Customer not registerd
        echo -e "\nI don't have a record for that phone number, what's your name?"

        read CUSTOMER_NAME
        INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
      fi
      #Triming the names
      SERVICE_NAME=$(echo $SERVICE_NAME | sed -r 's/^ *| *$//g')
      CUSTOMER_NAME=$(echo $CUSTOMER_NAME | sed -r 's/^ *| *$//g')

      echo -e "\nWhat time would you like your $SERVICE_NAME, $CUSTOMER_NAME?"
      
      read SERVICE_TIME
      
      # Inserting an appointment
      CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
      INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")

      # Goodbye message
      echo -e "I have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
    fi
  fi
}

echo -e "~~~~~ MY SALON ~~~~~\n"
MAIN_MENU "Welcome to My Salon, how can I help you?"