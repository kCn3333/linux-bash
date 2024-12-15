import requests
from requests.auth import HTTPDigestAuth
from datetime import datetime
import xml.etree.ElementTree as ET

def load_config(config_file):
    """
    Wczytuje dane konfiguracyjne z pliku.
    
    :param config_file: Ścieżka do pliku konfiguracyjnego
    :return: Słownik z ustawieniami kamery
    """
    config = {}
    try:
        with open(config_file, 'r') as file:
            for line in file:
                if '=' in line:
                    key, value = line.strip().split('=', 1)
                    config[key] = value
    except FileNotFoundError:
        print(f"Błąd: Plik konfiguracyjny '{config_file}' nie istnieje.")
    except Exception as e:
        print(f"Błąd podczas wczytywania konfiguracji: {e}")
    return config


def get_daily_distribution(ip, port, username, password, track_id):
    url = f"http://{ip}:{port}/ISAPI/ContentMgmt/record/tracks/{track_id}/dailyDistribution"
    headers = {
        "Content-Type": "application/xml",
    }
    # XML zgodny z dokumentacją
    data = f"""<?xml version="1.0" encoding="UTF-8"?>
    <trackDailyParam version="2.0" xmlns="http://www.hikvision.com/ver20/XMLSchema">
        <trackID>{track_id}</trackID>
    </trackDailyParam>"""
    
    # Debugowanie żądania
    print("Wysyłanie żądania do kamery...")
    print(f"URL: {url}")
    print(f"XML wysyłane:\n{data}")
    
    # Wysłanie żądania
    response = requests.post(
        url,
        headers=headers,
        auth=HTTPDigestAuth(username, password),
        data=data
    )
    
    # Debugowanie odpowiedzi
    print("Otrzymana odpowiedź z kamery:")
    print(f"Status code: {response.status_code}")
    print(response.text)
    
    # Analiza odpowiedzi
    if response.status_code == 200:
        try:
            root = ET.fromstring(response.content)
            # Parsowanie dostępnych dat
            dates = [date.text for date in root.findall(".//date")]
            return dates
        except Exception as e:
            print("Błąd przy parsowaniu XML:", e)
            return []
    else:
        print(f"Błąd przy pobieraniu dystrybucji dziennej. Kod błędu: {response.status_code}")
        print(response.text)
        return []





def parse_daily_distribution(response_content):
    """
    Parsuje odpowiedź XML i zwraca listę dat z dostępnością nagrań.
    
    :param response_content: Treść odpowiedzi XML
    :return: Lista dostępnych dat
    """
    available_dates = []
    try:
        root = ET.fromstring(response_content)
        namespace = {'ns': 'http://www.isapi.com/ver20/XMLSchema'}

        for date_item in root.findall('.//ns:date', namespace):
            available_dates.append(date_item.text)
    except ET.ParseError as e:
        print(f"Błąd parsowania XML: {e}")

    return available_dates


def search_video_files_by_date(ip, port, username, password, track_id, start_time, end_time):
    """
    Wyszukuje pliki wideo w określonym zakresie czasowym.
    
    :param ip: Adres IP kamery
    :param port: Port kamery
    :param username: Nazwa użytkownika
    :param password: Hasło
    :param track_id: Identyfikator ścieżki nagrań
    :param start_time: Czas początkowy w formacie ISO (np. 2023-01-01T00:00:00Z)
    :param end_time: Czas końcowy w formacie ISO
    :return: Lista znalezionych nagrań
    """
    search_request = f"""
    <CMSearchDescription>
        <searchID>{datetime.now().timestamp()}</searchID>
        <trackIDList>
            <trackID>{track_id}</trackID>
        </trackIDList>
        <timeSpanList>
            <timeSpan>
                <startTime>{start_time}</startTime>
                <endTime>{end_time}</endTime>
            </timeSpan>
        </timeSpanList>
        <maxResults>40</maxResults>
        <searchResultPostion>0</searchResultPostion>
        <metadataList>
            <metadataDescriptor>//recordType.meta.std-cgi.com</metadataDescriptor>
        </metadataList>
    </CMSearchDescription>
    """
    
    url = f"http://{ip}:{port}/ISAPI/ContentMgmt/search"
    headers = {'Content-Type': 'application/xml'}

    response = requests.post(
        url,
        auth=HTTPDigestAuth(username, password),
        headers=headers,
        data=search_request
    )

    if response.status_code == 200:
        print("Otrzymano wyniki wyszukiwania.")
        return parse_video_files(response.content)
    else:
        print(f"Błąd przy wyszukiwaniu nagrań. Kod błędu: {response.status_code}")
        print(response.text)
        return None


def parse_video_files(response_content):
    """
    Parsuje odpowiedź XML i zwraca listę znalezionych nagrań.
    
    :param response_content: Treść odpowiedzi XML
    :return: Lista nagrań (słowniki z informacjami o czasie startu, końca i URI)
    """
    video_files = []
    try:
        root = ET.fromstring(response_content)
        namespace = {'ns': 'http://www.isapi.com/ver20/XMLSchema'}

        for match_item in root.findall('.//ns:searchMatchItem', namespace):
            start_time = match_item.find('.//ns:startTime', namespace).text
            end_time = match_item.find('.//ns:endTime', namespace).text
            playback_uri = match_item.find('.//ns:playbackURI', namespace).text

            video_files.append({
                'start_time': start_time,
                'end_time': end_time,
                'playback_uri': playback_uri
            })
    except ET.ParseError as e:
        print(f"Błąd parsowania XML: {e}")

    return video_files


if __name__ == "__main__":
    # Ścieżka do pliku konfiguracyjnego
    config_file = "camera_config.txt"
    config = load_config(config_file)

    if not config:
        print("Nie udało się wczytać konfiguracji. Sprawdź plik konfiguracyjny.")
    else:
        ip = config.get("ip")
        port = config.get("port", "80")
        username = config.get("user")
        password = config.get("password")
        track_id = config.get("id", "101")

        print("Pobieranie dostępnych dat nagrań...")
        dates = get_daily_distribution(ip, port, username, password, track_id)
        if dates:
            print("Dostępne daty nagrań:")
            for date in dates:
                print(date)

            # Wybór daty do wyszukiwania nagrań
            selected_date = dates[-1]  # Ostatnia dostępna data
            start_time = f"{selected_date}T00:00:00Z"
            end_time = f"{selected_date}T23:59:59Z"

            print(f"\nWyszukiwanie nagrań dla dnia: {selected_date}")
            video_files = search_video_files_by_date(ip, port, username, password, track_id, start_time, end_time)
            if video_files:
                print("\nZnalezione nagrania:")
                for file in video_files:
                    print(f"Start: {file['start_time']}, End: {file['end_time']}, URI: {file['playback_uri']}")
            else:
                print("Brak nagrań dla wybranego dnia.")
        else:
            print("Brak dostępnych dat.")
