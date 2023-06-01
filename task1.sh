#!/bin/bash

# Function for permissions
set_permissions() {
  local user=$1
  local file=$2
  sudo chown "$user:$user" "$file"
  sudo chmod 600 "$file"
}



# Create user doctors

for i in {1..3}; do
  username="doctor$i"
  home_dir="/home/$username"
  sudo useradd -m -d "$home_dir" -s /bin/bash "$username"
 
  echo "Slot:  Wing:" | sudo tee "$home_dir/Available.txt"
  echo "Slot: Wing: Patient: " | sudo tee "$home_dir/Appointment.txt"
   set_permissions "$username" "$home_dir/Available.txt"
   set_permissions "$username" "$home_dir/Appointment.txt"
done



# Create user patients

for i in {1..3}; do
  username="patient$i"
  home_dir="/home/$username"
  sudo useradd -m -d "$home_dir" -s /bin/bash "$username"
  
  echo "Slots: " | sudo tee "$home_dir/PatientDetails.txt"
  echo "Symptoms: " | sudo tee "$home_dir/Prescription.txt"
  set_permissions "$username" "$home_dir/PatientDetails.txt"
  set_permissions "$username" "$home_dir/Prescription.txt"
done

# Create usr wing admins

wing_admins=("wingadmin1" "wingadmin2" "wingadmin3")
for admin in "${wing_admins[@]}"; do
  home_dir="/home/$admin"
  sudo useradd -m -d "$home_dir" -s /bin/bash "$admin"
  sudo mkdir "$home_dir/Patient"
  sudo mkdir "$home_dir/Doctor"
   echo "InPatient.txt" | sudo tee "$home_dir/Patient/InPatient.txt"
   echo "InDoctor.txt" | sudo tee "$home_dir/Doctor/InDoctor.txt"
  set_permissions "$admin" "$home_dir/Patient/InPatient.txt"
  set_permissions "$admin" "$home_dir/Doctor/InDoctor.txt"
done



# Appointment function
echo 
sudo echo "Appointment functionality:"
read -p "Enter doctor's username: " doctor_username
read -p "Enter patient's username: " patient_username
read -p "Enter chosen timing: " chosen_timing

# Update doctor's shift 

doctor_home="/home/$doctor_username"
echo "Slots: $chosen_timing" | sudo tee "$doctor_home/Available.txt"

# Update inDoctor.txt 

wing_name="${doctor_home##*/}"
admin_home="/home/wingadmin$wing_name"
echo "Doctor: $doctor_username, Timings: $chosen_timing" | sudo tee "$admin_home/InDoctor.txt"

# Check for time

if grep -q "$chosen_timing" "$doctor_home/Available.txt"; then

  # Update patient's appointment
  
  patient_home="/home/$patient_username"
  echo "Appointment with $doctor_username, Timing: $chosen_timing" | sudo tee "$patient_home/Appointment.txt"

  # Update inPatient.txt
  
  echo "Patient: $patient_username, Doctor: $doctor_username, Timing: $chosen_timing" | sudo tee "$admin_home/Patient/InPatient.txt"
else
  sudo echo "Chosen timing is not available. Please choose another timing."
fi



