#!/bin/bash

# SKRIPTA ZA DEMONSTRACIJU PASSWORD MANAGERA
# Demonstrirane su sve funkcionalnosti password managera
# Uključujući inicijalizaciju, dodavanje, dohvaćanje i ažuriranje lozinki
# Skripta se pokreće iz terminala unosom naredbe: bash demo.sh ili ./demo.sh nakon što se dodijele prava za izvršavanje skripti (chmod +x demo.sh)
# Skripta je na engleskom jeziku kako bi mogao kasnije objaviti na GitHubu

clear

# Definiranje varijabli za master lozinke
CORRECT_MASTER_PASSWORD="SuperSecret123"
WRONG_MASTER_PASSWORD="WrongPassword123"

# Brišemo prethodnu datoteku sifrice4.bin ako postoji
echo "Cleaning up existing data file, if any..."
rm -f sifrice4.bin
echo "Done cleaning."

# Uvod
echo -e "\033[1;34mWelcome to the Interactive Demo of the Password Manager!\033[0m\n"
echo "This demo will guide you through initializing, adding, retrieving, and updating passwords within the Password Manager."
echo "You will also see what happens when an incorrect master password is used."
echo -e "Let's explore how it ensures the security of your passwords through encryption.\n"

read -p "Press any key to start the demo... " -n1 -s
echo -e "\n\n"

# Napravi executable
chmod +x password_manager.py

# 1. Inicijalizacija Password Managera
echo -e "\033[1;32m1. Initializing the Password Manager\033[0m"
echo "We'll start by initializing the password database with a master password."
echo "This process generates an encrypted file to securely store your passwords."
echo -e "\n\033[0;33mCommand: ./password_manager.py init '$CORRECT_MASTER_PASSWORD'\033[0m"
read -p "Press any key to run the above command... " -n1 -s
echo -e "\n"
./password_manager.py init "$CORRECT_MASTER_PASSWORD"
echo -e "\n"
read -p "Press any key to continue." -n1 -s
echo -e "\n"

# 2. Dodavanje nove lozinke
echo -e "\033[1;32m2. Adding a New Password\033[0m"
echo "Next, let's add a new password for 'www.example.com'."
echo "The password will be encrypted and stored securely."
echo -e "\n\033[0;33mCommand: ./password_manager.py put '$CORRECT_MASTER_PASSWORD' 'www.example.com' 'examplePassword'\033[0m"
read -p "Press any key to run the above command... " -n1 -s
echo -e "\n"
./password_manager.py put "$CORRECT_MASTER_PASSWORD" "www.example.com" "examplePassword"
read -p "Press any key to continue." -n1 -s
echo -e "\n"

# 3. Dohvaćanje lozinke
echo -e "\033[1;32m3. Retrieving a Password\033[0m"
echo "Now, let's retrieve the stored password for 'www.example.com'."
echo -e "\n\033[0;33mCommand: ./password_manager.py get '$CORRECT_MASTER_PASSWORD' 'www.example.com'\033[0m"
read -p "Press any key to run the above command... " -n1 -s
echo -e "\n"
./password_manager.py get "$CORRECT_MASTER_PASSWORD" "www.example.com"
read -p "Press any key to continue." -n1 -s
echo -e "\n"

# 4. Ažuriranje postojeće lozinke
echo -e "\033[1;32m4. Updating an Existing Password\033[0m"
echo "Passwords change. Let's update the password for 'www.example.com'."
echo -e "\n\033[0;33mCommand: ./password_manager.py put '$CORRECT_MASTER_PASSWORD' 'www.example.com' 'newPassword123'\033[0m"
read -p "Press any key to run the above command... " -n1 -s
echo -e "\n"
./password_manager.py put "$CORRECT_MASTER_PASSWORD" "www.example.com" "newPassword123"
echo -e "\n\033[0;33mCommand: ./password_manager.py get '$CORRECT_MASTER_PASSWORD' 'www.example.com'\033[0m"
./password_manager.py get "$CORRECT_MASTER_PASSWORD" "www.example.com"
read -p "Press any key to continue."  -n1 -s
echo -e "\n"

# 5. Pokušaj s pogrešnom master lozinkom
echo -e "\033[1;32m5. Attempting Access with Incorrect Master Password\033[0m"
echo "What happens if we use the wrong master password? Let's find out."
echo -e "\n\033[0;33mCommand: ./password_manager.py get '$WRONG_MASTER_PASSWORD' 'www.example.com'\033[0m"
read -p "Press any key to run the above command... " -n1 -s
echo -e "\n"
./password_manager.py get "$WRONG_MASTER_PASSWORD" "www.example.com"
read -p "Press any key to continue."  -n1 -s
echo -e "\n"

# 6. Demonstracija pokušaja dodavanja lozinke s pogrešnom master lozinkom
echo -e "\033[1;32m6. Adding Password with Incorrect Master Password\033[0m"
echo "Let's try to add a password using the incorrect master password."
echo -e "\n\033[0;33mCommand: ./password_manager.py put '$WRONG_MASTER_PASSWORD' 'www.fake-site.com' 'fakePassword'\033[0m"
read -p "Press any key to run the above command... " -n1 -s
echo -e "\n"
./password_manager.py put "$WRONG_MASTER_PASSWORD" "www.fake-site.com" "fakePassword"
read -p "Press any key to continue."  -n1 -s
echo -e "\n"

# 7. Dodavanje dodatne lozinke s ispravnom master lozinkom
echo -e "\033[1;32m7. Adding Another Password with Correct Master Password\033[0m"
echo "Finally, let's add another password, this time for 'www.another-site.com'."
echo -e "\n\033[0;33mCommand: ./password_manager.py put '$CORRECT_MASTER_PASSWORD' 'www.another-site.com' 'anotherPassword123'\033[0m"
read -p "Press any key to run the above command... " -n1 -s
echo -e "\n"
./password_manager.py put "$CORRECT_MASTER_PASSWORD" "www.another-site.com" "anotherPassword123"
read -p "Press any key to continue."  -n1 -s
echo -e "\n"

# 8. Dohvaćanje dodatne lozinke
echo -e "\033[1;32m8. Retrieving the Additional Password\033[0m"
echo "To ensure our new password was added successfully, let's retrieve it."
echo -e "\n\033[0;33mCommand: ./password_manager.py get '$CORRECT_MASTER_PASSWORD' 'www.another-site.com'\033[0m"
read -p "Press any key to run the above command... " -n1 -s
echo -e "\n"
./password_manager.py get "$CORRECT_MASTER_PASSWORD" "www.another-site.com"
echo -e "\n"

echo -e "\033[1;34mDemo completed. Thank you for exploring the Password Manager!\033[0m"

