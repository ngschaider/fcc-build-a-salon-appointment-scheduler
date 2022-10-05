#!/bin/bash

PSQL='psql -X --no-align --tuples-only --username=freecodecamp --dbname=salon -c'

SERVICES_MENU() {
	$PSQL "SELECT service_id, name FROM services" | while IFS="|" read SERVICE_ID NAME
	do
		echo $SERVICE_ID")" $NAME
	done

	echo "Please select a service:"
	read SERVICE_ID_SELECTED

	SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")
	if [[ -z $SERVICE_NAME ]]
	then
		SERVICES_MENU
		return
	else
		CUSTOMER_MENU "$SERVICE_ID_SELECTED" "$SERVICE_NAME"
	fi
}

CUSTOMER_MENU() {
	SERVICE_ID_SELECTED=$1
	SERVICE_NAME=$2

	echo "Please input your phone number:"
	read CUSTOMER_PHONE

	CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")
	if [[ -z $CUSTOMER_NAME ]]
	then
		echo ""
		echo "You are not a registered customer."
		echo "Please input your name:"
		read CUSTOMER_NAME

		INSERT_RES=$($PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
	fi

	CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")

	echo ""
	echo "Please input the time of your appointment:"
	read SERVICE_TIME

	INSERT_RES=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES ($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")

	echo "I have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
}

SERVICES_MENU
