#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=periodic_table -t --no-align -c"

display_periodic_data () {

  # Retrieve periodic data by atomic_number
  PERIODIC_DATA="$($PSQL "select el.atomic_number, el.symbol, el.name, pr.atomic_mass, pr.melting_point_celsius, pr.boiling_point_celsius, ty.type
  from elements el
  join properties pr ON el.atomic_number=pr.atomic_number
  join types ty  ON pr.type_id=ty.type_id
  where el.atomic_number=$1")"

  # Split the PERIODIC_DATA string by delimiter "|" and assign values to variables
  IFS='|' read -r atomic_number symbol name atomic_mass melting_point boiling_point type <<<"$PERIODIC_DATA"

  echo "The element with atomic number $atomic_number is $name ($symbol). It's a $type, with a mass of $atomic_mass amu. $name has a melting point of $melting_point celsius and a boiling point of $boiling_point celsius."

}

# Check input parameter
if [ $# -eq 0 ]; then
    echo "Please provide an element as an argument."

elif [ $# -eq 1 ]; then
    # Check parameter is number?
    if [[ $1 =~ ^[0-9]+$ ]]; then
      # Parameter is a number
      # Find atomic number in elements table by input atomic number
      ATOMIC_NUMBER="$($PSQL "SELECT atomic_number FROM elements WHERE atomic_number=$1 ")"
    else
      # Parameter is not a number
      # Find atomic number in elements table by symbol or name
      ATOMIC_NUMBER="$($PSQL "SELECT atomic_number FROM elements WHERE symbol='$1' OR name='$1' ")"
    fi
    # echo "ATOMIC_NUMBER = $ATOMIC_NUMBER"
    # Atomic number not found in db
    if [ -z "$ATOMIC_NUMBER" ]; then
      echo "I could not find that element in the database."
    # Atomic number was found
    else
      display_periodic_data $ATOMIC_NUMBER
    fi
elif [ $# -gt 1 ]; then
    echo "Please input only one parameter."
fi