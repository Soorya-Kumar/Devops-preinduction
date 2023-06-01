#!/bin/bash

# Function to set permissions
set_permissions() {
  local user=$1
  local file=$2
  sudo chown "$user:$user" "$file"
  sudo chmod 600 "$file"
}



# Function to check if a wing is full
is_wing_full() {
  local wing_name=$1
  local patients_count=$(grep -c "Wing: $wing_name" "patient_rooms.txt")
  if [[ $patients_count -ge 10 ]]; then
    return 0
  else
    return 1
  fi
}



# Function to check if a wing has reached its capacity for a specific type of patient
is_wing_at_capacity() {
  local wing_name=$1
  local patient_type=$2
  local patients_count=$(grep -c "Wing: $wing_name, Type: $patient_type" "patient_rooms.txt")
  case $patient_type in
    infectious)
      if [[ $patients_count -ge 4 ]]; then
        return 0 # Wing is at capacity for infectious patients
      fi
      ;;
    mental)
      if [[ $patients_count -ge 3 ]]; then
        return 0 # Wing is at capacity for mental patients
      fi
      ;;
    physical)
      if [[ $patients_count -ge 7 ]]; then
        return 0 # Wing is at capacity for physical patients
      fi
      ;;
  esac
  return 1 # Wing is not at capacity for the specified patient type
}



# Function to move the oldest patient to a different wing
move_oldest_patient() {
  local patient_type=$1
  local current_wing=$2
  local patient_to_move=$(grep "Wing: $current_wing, Type: $patient_type" "patient_rooms.txt" | awk 'BEGIN{FS=","} {print $1}' | sort | head -n 1)
  local patient_wing=$(grep "Patient: $patient_to_move" "patient_rooms.txt" | awk 'BEGIN{FS=","} {print $2}')
  local target_wing

  case $patient_type in
    infectious)
      target_wing="wing1"
      ;;
    mental)
      target_wing="wing2"
      ;;
    physical)
      target_wing="wing3"
      ;;
  esac

  echo "Moving patient $patient_to_move from $current_wing to $target_wing"

  # Update patient's wing in the patient_rooms.txt file
  sed -i "s/Wing: $current_wing, Type: $patient_type/Wing: $target_wing, Type: $patient_type/" "patient_rooms.txt"

  # Update patient's wing in the InPatient.txt file for the respective wing admin
  wing_admin_home="/home/wingadmin$patient_wing"
  sed -i "s/Wing: $current_wing, Type: $patient_type/Wing: $target_wing, Type: $patient_type/" "$wing_admin_home/Patient/InPatient.txt"
}




# Room allotment functionality
echo "Room allotment functionality:"
read -p "Enter patient's username: " patient_username
read -p "Enter doctor's username: " doctor_username
read -p "Enter patient type [infectious, mental, physical]: " patient_type

patient_home="/home/$patient_username"
doctor_home="/home/$doctor_username"
wing_name="${doctor_home##*/}"
wing_admin_home="/home/wingadmin$wing_name"

# Check if the patient's wing violates the conditions
if [[ $patient_type == "infectious" ]]; then
  if ! grep -q "Wing: $wing_name, Type: mental" "patient_rooms.txt" && ! grep -q "Wing: $wing_name, Type: infectious" "patient_rooms.txt" && ! grep -q "Wing: $wing_name, Type: physical" "patient_rooms.txt"; then
    # Move the oldest patient to a different wing
    move_oldest_patient "infectious" "$wing_name"
  fi
fi






# Check if the patient's wing is full or at capacity for the patient type
if is_wing_full "$wing_name" || is_wing_at_capacity "$wing_name" "$patient_type"; then
  # Find an available wing
  if ! is_wing_full "wing1"; then
    wing_name="wing1"
  elif ! is_wing_full "wing2"; then
    wing_name="wing2"
  elif ! is_wing_full "wing3"; then
    wing_name="wing3"
  else
    echo "No available wings to accommodate the patient."
    exit 1
  fi
fi



# Update patient's wing in the patient_rooms.txt file
echo "Patient: $patient_username, Wing: $wing_name, Type: $patient_type" | sudo tee "patient_rooms.txt"

# Update patient's wing in the InPatient.txt file for the respective wing admin
echo "Patient: $patient_username, Wing: $wing_name, Type: $patient_type" | sudo tee "$wing_admin_home/Patient/InPatient.txt"

echo "Patient $patient_username has been allotted to $wing_name wing."

