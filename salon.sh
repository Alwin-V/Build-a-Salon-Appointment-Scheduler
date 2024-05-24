#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ MY SALON ~~~~~\n"

# Fonction pour afficher le menu principal
MAIN_MENU() {
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi

  # Récupérer et afficher les services
  echo "Here are the services we offer:"
  SERVICES=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id")
  echo "$SERVICES" | while read SERVICE_ID BAR SERVICE_NAME
  do
    echo "$SERVICE_ID) $SERVICE_NAME"
  done

  echo -e "\nPlease enter the service_id you would like to book:"
  read SERVICE_ID_SELECTED

  # Vérifier si le service existe
  SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")

  if [[ -z $SERVICE_NAME ]]
  then
    # Si le service n'existe pas, afficher le menu à nouveau
    MAIN_MENU "Please enter a valid service ID."
  else
    echo -e "\nPlease enter your phone number:"
    read CUSTOMER_PHONE

    # Vérifier si le client existe déjà
    CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")

    # Si le client n'existe pas
    if [[ -z $CUSTOMER_NAME ]]
    then
      echo -e "\nI don't have a record for that phone number, what's your name?"
      read CUSTOMER_NAME
      # Insérer le nouveau client dans la base de données
      INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
    fi

    echo -e "\nWhat time would you like your $(echo $SERVICE_NAME | sed 's/ //g')?"
    read SERVICE_TIME

    # Récupérer le customer_id
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")

    # Insérer le rendez-vous dans la base de données
    INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")

    echo -e "\nI have put you down for a $(echo $SERVICE_NAME | sed 's/ //g') at $SERVICE_TIME, $(echo $CUSTOMER_NAME | sed 's/ //g')."
  fi
}

# Exemple de fonction pour quitter
EXIT() {
  echo -e "\nThank you for visiting My Salon. Goodbye!\n"
  exit 0
}

# Appeler la fonction MAIN_MENU
MAIN_MENU
