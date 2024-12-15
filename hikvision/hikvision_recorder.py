import requests
from requests.auth import HTTPDigestAuth
from xml.etree import ElementTree as ET

def daily_distribution(ip, user, password, track_id, year, month, day_of_month, record=True, record_type="time"):
    # Endpoint URL, który odpowiada za dystrybucję dzienną
    url = f"http://{ip}/ISAPI/ContentMgmt/record/tracks/{track_id}/dailyDistribution"
    
    # Tworzenie XML w odpowiednim formacie
    root = ET.Element("trackDailyDistribution", version="1.0", xmlns="http://www.isapi.com/ver20/XMLSchema")
    day_list = ET.SubElement(root, "dayList")
    
    day = ET.SubElement(day_list, "day")
    ET.SubElement(day, "id").text = "1"  # ID dla tego dnia (można zmieniać)
    ET.SubElement(day, "dayOfMonth").text = str(day_of_month)  # Dzień miesiąca
    ET.SubElement(day, "record").text = str(record).lower()  # Określenie, czy nagranie ma mieć miejsce
    ET.SubElement(day, "recordType").text = record_type  # Typ nagrania (np. 'time' lub 'event')
    
    # Generowanie XML
    xml_data = ET.tostring(root, encoding="utf-8", method="xml").decode()

    # Nagłówki, w tym Content-Type do XML
    headers = {
        "Content-Type": "application/xml"
    }

    # Uwierzytelnianie za pomocą Digest Authentication
    auth = HTTPDigestAuth(user, password)

    # Wysłanie zapytania POST z danymi XML
    response = requests.post(url, headers=headers, data=xml_data, auth=auth)

    # Sprawdzenie odpowiedzi
    if response.status_code == 200:
        print("Successfully updated daily distribution.")
        print(response.text)  # Możesz także przeanalizować odpowiedź serwera
    else:
        print(f"Failed to update daily distribution. Status code: {response.status_code}")
        print(response.text)

# Przykład użycia funkcji:
ip = "192.168.0.64"
user = "admin"
password = "69DupaDupa"
track_id = 101  # ID ścieżki, którą chcesz zaktualizować
year = 2024
month = 11
day_of_month = 22  # Dzień w miesiącu, dla którego ustawiamy rozkład
record = True  # Czy ma być nagranie
record_type = "time"  # Typ nagrania: "time" (ciągłe), "event" (na podstawie zdarzeń)

# Wywołanie funkcji
if __name__ == "__main__":
    daily_distribution(ip, user, password, track_id, year, month, day_of_month, record, record_type)
