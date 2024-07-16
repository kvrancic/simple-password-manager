#!/usr/bin/env python3
# shebang mi omogućava da pokrenem skriptu s ./ime_skripte.py

import sys
from Crypto.Protocol.KDF import PBKDF2
from Crypto.Cipher import AES
from Crypto.Random import get_random_bytes
from Crypto.Hash import SHA256, SHA512

# Definicija konstanti za kriptografske operacije
# Vrijednosti preuzete s https://www.comparitech.com/blog/information-security/key-derivation-function-kdf/#What_are_key_derivation_functions_KDFs_used_for

FILE_NAME = 'sifrice4.bin'
SALT_SIZE = 16
IV_SIZE = 12  # AES GCM standardno koristi nonce veličine 12 bajta
KEY_SIZE = 32
ITERATIONS = 310000  # Preporučeni broj iteracija za PBKDF2

def initialisation(master_password):
    """Inicializacija upravitelja lozinkama stvaranjem konfiguracijske datoteke."""

    salt = get_random_bytes(SALT_SIZE)  # Generiranje nasumičnog salta
    key = PBKDF2(master_password, salt, dkLen=KEY_SIZE, count=ITERATIONS, hmac_hash_module=SHA512)  # Izvod ključa
    cipher = AES.new(key, AES.MODE_GCM, nonce=get_random_bytes(IV_SIZE))  # Inicijalizacija šifrera
    ciphertext, tag = cipher.encrypt_and_digest(b" ")  
    
    # Spremanje konfiguracije u datoteku
    with open(FILE_NAME, 'wb') as file:
        file.write(salt + cipher.nonce + tag + ciphertext)
    print("Initialization complete. Password manager is ready to use.")

def check_master_password(master_password):
    """Provjera ispravnosti master lozinke."""

    try:
        with open(FILE_NAME, 'rb') as file:
            salt = file.read(SALT_SIZE)
            nonce = file.read(IV_SIZE)
            tag = file.read(16)
            ciphertext = file.read()
            
        key = PBKDF2(master_password, salt, dkLen=KEY_SIZE, count=ITERATIONS, hmac_hash_module=SHA512)
        cipher = AES.new(key, AES.MODE_GCM, nonce=nonce)
        plaintext = cipher.decrypt_and_verify(ciphertext, tag)
        
        return plaintext 
    except (ValueError, KeyError, FileNotFoundError) as e:
        sys.exit(f"Error: Incorrect master password causing {str(e)}")

def pad_data(data, length=256):
    return data.ljust(length)

def add_password(master_password, address, password):
    """Dodavanje nove lozinke ili ažuriranje postojeće."""

    existing_data = check_master_password(master_password)  # Provjera master lozinke
    
    # Paddaj do 256 mjesta kako napadač ne bi mogao znati duljinu
    padded_password = pad_data(password)
    
    new_data = update_password_data(existing_data, address, padded_password)  # Ažuriranje podataka

    # Ponovno šifriranje s novim saltom i nonce
    salt = get_random_bytes(SALT_SIZE)
    key = PBKDF2(master_password, salt, dkLen=KEY_SIZE, count=ITERATIONS, hmac_hash_module=SHA512)
    cipher = AES.new(key, AES.MODE_GCM, nonce=get_random_bytes(IV_SIZE))
    
    ciphertext, tag = cipher.encrypt_and_digest(new_data)
    
    with open(FILE_NAME, 'wb') as file:
        file.write(salt + cipher.nonce + tag + ciphertext)
    print(f"Password for {address} stored successfully.")

def update_password_data(existing_data, address, new_password):
    """Ažuriranje podataka s novom lozinkom."""

    data_str = existing_data.decode()
    lines = data_str.split('\n') if data_str else []
    updated_lines = [line for line in lines if not line.startswith(f"{address} ")]
    updated_lines.append(f"{address} {new_password}")
    return '\n'.join(updated_lines).encode()

def get_password(master_password, address):
    """Dohvaćanje spremljene lozinke za zadani unos adrese."""
    existing_data = check_master_password(master_password)  # Provjera master lozinke
    data_str = existing_data.decode()
    for line in data_str.split('\n'):
        if line.startswith(f"{address} "):
            password = line.split(' ', 1)[1]
            print(f"Password for {address} is: {password.rstrip()}")
            return
    print(f"Operation failed.")

if __name__ == '__main__':
    if len(sys.argv) < 3:
        print("Usage: {} [init|put|get] master_password [address] [password]".format(sys.argv[0]))
        sys.exit(1)

    # Numeriranje argumenata ovisi o tome na koji način pozivamo program: npr. python3 imedatoteke.py ili ./exe
    action, num = "", 0
    for i in range(1, len(sys.argv)):
        if sys.argv[i] in ["init", "put", "get"]:
            action = sys.argv[i]
            num = i

    if not action: 
        print("Invalid command")

    master_password = sys.argv[num + 1]

    try: 
        if action == "init":
            initialisation(master_password)
        elif action == "put":
            add_password(master_password, sys.argv[num + 2], sys.argv[num + 3])
        elif action == "get":
            get_password(master_password, sys.argv[num + 2])
    except IndexError:
        print("Invalid or missing arguments. Try again.")
        sys.exit(1)