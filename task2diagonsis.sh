#!/bin/bash

# Function for permissions
set_permissions() {
  local user=$1
  local file=$2
  sudo chown "$user:$user" "$file"
  sudo chmod 600 "$file"
}

# Diagnosis and Prescription function
echo "Enter the patient's diagnosis and prescription:"
read -p "Enter doctor's username: " doctor_username
read -p "Enter patient's username: " patient_username
read -p "Enter diagnosis [infectious, mental, physical, critical]: " diagnosis
read -p "Enter date and time of diagnosis: " diagnosis_datetime
read -p "Enter morning medicine: " morning_med
read -p "Enter afternoon medicine: " afternoon_med
read -p "Enter dinner medicine: " dinner_med

# Update PatientDetails.txt
doctor_home="/home/$doctor_username"
patient_home="/home/$patient_username"
echo "Diagnosis: $diagnosis, Date and Time: $diagnosis_datetime" | sudo tee "$patient_home/PatientDetails.txt"
set_permissions "$doctor_username" "$patient_home/PatientDetails.txt"

# Update Prescription.txt
echo "Morning: $morning_med" | sudo tee "$patient_home/Prescription.txt"
echo "Afternoon: $afternoon_med" | sudo tee "$patient_home/Prescription.txt"
echo "Dinner: $dinner_med" | sudo tee "$patient_home/Prescription.txt"
set_permissions "$doctor_username" "$patient_home/Prescription.txt"

