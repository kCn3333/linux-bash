import requests
from requests.auth import HTTPDigestAuth
import xml.etree.ElementTree as ET
import os
from colorama import Fore, Style, init

# Inicjalizacja colorama
init(autoreset=True)

# Funkcja do odczytu konfiguracji
def read_config(file_path):
    if not os.path.exists(file_path):
        print(f"Plik konfiguracyjny {file_path} nie istnieje.")
        return None
    
    config = {}
    with open(file_path, "r") as file:
        for line in file:
            key, value = line.strip().split("=", 1)
            config[key.strip()] = value.strip()
    return config

# Funkcja do połączenia z kamerą i pobrania danych
def connect_to_camera(config, endpoint):
    url = f"http://{config['ip']}:{config['port']}{endpoint}"
    try:
        response = requests.get(url, auth=HTTPDigestAuth(config['user'], config['password']))
        if response.status_code == 200:
            print(Fore.GREEN + "Połączenie z kamerą zostało ustanowione.")
            return response.content
        else:
            print(Fore.RED + f"Nie udało się połączyć z kamerą. Kod błędu: {response.status_code}")
            return None
    except requests.RequestException as e:
        print(Fore.RED + f"Błąd połączenia: {e}")
        return None

# Funkcja do parsowania i wyświetlania danych XML
def parse_and_display_info(xml_data):
    try:
        # Uwzględniamy przestrzeń nazw
        namespaces = {'hikvision': 'http://www.hikvision.com/ver20/XMLSchema'}
        tree = ET.fromstring(xml_data)
        print(Fore.CYAN + "Informacje o kamerze:")
        
        # Przechodzimy przez elementy XML z przestrzenią nazw
        for element in tree:
            # Sprawdzamy, czy element ma przestrzeń nazw
            tag = element.tag.split('}')[-1]  # Usuwamy przestrzeń nazw
            print(Fore.YELLOW + f"{tag}: {element.text}")
    except ET.ParseError as e:
        print(Fore.RED + f"Błąd parsowania XML: {e}")

# Funkcja do pobierania i wyświetlania statystyk wideo z kamery
def get_video_files_stats(config):
    print(Fore.CYAN + "\nPobieranie plików wideo z kamery...")
    endpoint = "/ISAPI/ContentMgmt/search"  # Endpoint do pobrania informacji o plikach wideo
    xml_data = connect_to_camera(config, endpoint)
    
    if xml_data:
        try:
            # Uwzględniamy przestrzeń nazw
            namespaces = {'hikvision': 'http://www.hikvision.com/ver20/XMLSchema'}
            tree = ET.fromstring(xml_data)
            video_files = tree.findall(".//hikvision:FileInfo", namespaces)

            total_size = 0
            file_count = len(video_files)

            # Wyświetlanie tabeli z danymi
            print(Fore.CYAN + "\nStatystyki plików wideo:")
            print(Fore.GREEN + f"{'Nazwa Pliku':<30}{'Rozmiar (bytes)':<20}{'Start Time':<25}{'End Time':<25}")
            print(Fore.GREEN + "-"*100)

            # Iteracja po plikach wideo i sumowanie danych
            for video_file in video_files:
                file_name = video_file.find("hikvision:fileName", namespaces).text
                file_size = int(video_file.find("hikvision:fileSize", namespaces).text)
                start_time = video_file.find("hikvision:startTime", namespaces).text
                end_time = video_file.find("hikvision:endTime", namespaces).text
                
                # Suma rozmiarów plików
                total_size += file_size

                print(f"{file_name:<30}{file_size:<20}{start_time:<25}{end_time:<25}")

            # Wyświetlanie podsumowania
            print(Fore.GREEN + "-"*100)
            print(Fore.YELLOW + f"Liczba plików: {file_count}")
            print(Fore.YELLOW + f"Suma rozmiarów plików: {total_size} bytes")
        except ET.ParseError as e:
            print(Fore.RED + f"Błąd parsowania XML przy pobieraniu plików wideo: {e}")
    else:
        print(Fore.RED + "Nie udało się pobrać danych o plikach wideo.")

# Główna funkcja
def main():
    config_file = "camera_config.txt"  # Ścieżka do pliku konfiguracyjnego
    config = read_config(config_file)
    
    if not config:
        return

    print(Fore.CYAN + f"Łączenie z kamerą Hikvision na adresie {config['ip']}:{config['port']}...")
    xml_data = connect_to_camera(config, "/ISAPI/System/deviceInfo")
    
    if xml_data:
        parse_and_display_info(xml_data)
        get_video_files_stats(config)

if __name__ == "__main__":
    main()
