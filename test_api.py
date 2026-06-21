import urllib.request
import json
import html

def get_events():
    url = "https://www.bcnswing.org/wp-json/tribe/events/v1/events?per_page=10&status=publish"
    try:
        with urllib.request.urlopen(url) as response:
            data = json.loads(response.read().decode())
            events = data.get('events', [])

            print("=" * 60)
            print("  BCN SWING EVENTS - Propers esdeveniments")
            print("=" * 60)

            for i, event in enumerate(events, 1):
                title = html.unescape(event.get('title', 'Sense títol'))
                date = event.get('date', '')[:10]
                venue = event.get('venue', {}).get('venue', 'Sense lloc')
                city = event.get('venue', {}).get('city', '')
                categories = ', '.join([c.get('name', '') for c in event.get('categories', [])])
                url = event.get('url', '')

                print(f"\n{i}. {title}")
                print(f"   Data: {date}")
                print(f"   Lloc: {venue}, {city}" if city else f"   Lloc: {venue}")
                print(f"   Categoria: {categories}")
                print(f"   Web: {url}")

            print("\n" + "=" * 60)
            print(f"Total: {len(events)} esdeveniments carregats")
            print("=" * 60)

    except Exception as e:
        print(f"Error: {e}")

if __name__ == "__main__":
    get_events()
