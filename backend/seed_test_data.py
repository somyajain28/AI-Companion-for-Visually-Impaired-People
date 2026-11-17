"""
Seeds realistic test data for AI Companion Database.
Creates users, preferences, emergency contacts, locations, and memory vault items.
"""
from app import app
from database import query_db

client = app.test_client()

test_users_data = [
    {
        'user': {
            'user_name': 'Ananya Iyer',
            'user_email': 'ananya.iyer@example.com',
            'date_of_birth': '14th April 1995',
            'phone_number': '9820123456',
            'password': 'AnanyaPass@2026',
            'preferred_language': 'en'
        },
        'emergency_contacts': [
            {'name': 'Ramesh Iyer', 'relationship': 'Father', 'phone_number': '9820987654'}
        ],
        'locations': [
            {'location_name': 'Greenfield Apts, Tower 4, Flat 302, Bengaluru', 'location_type': 'Home'},
            {'location_name': 'Indiranagar Metro Station Gate 1', 'location_type': 'Transit'}
        ],
        'saved_info': [
            {'title': 'Medicines Schedule', 'content': 'Morning blood pressure tablet after breakfast in the blue pill organizer.', 'type': 'voice_note'},
            {'title': 'Spare House Keys', 'content': 'Placed in the small wooden box inside the hall bookshelf second rack.', 'type': 'voice_note'}
        ]
    },
    {
        'user': {
            'user_name': 'Vikram Singh',
            'user_email': 'vikram.singh@example.com',
            'date_of_birth': '2nd October 1982',
            'phone_number': '9871122334',
            'password': 'Vikram@SafePass99',
            'preferred_language': 'en'
        },
        'emergency_contacts': [
            {'name': 'Pooja Singh', 'relationship': 'Wife', 'phone_number': '9871998877'}
        ],
        'locations': [
            {'location_name': 'Sector 62 Tech Park, Tower B, Noida', 'location_type': 'Office'},
            {'location_name': 'City Central Hospital, Main OPD', 'location_type': 'Hospital'}
        ],
        'saved_info': [
            {'title': 'Walking Cane Location', 'content': 'Foldable cane is kept beside the shoe rack near the front doorway.', 'type': 'voice_note'},
            {'title': 'Laptop Charger', 'content': 'Black 65 watt Type-C charger plugged in behind the study desk.', 'type': 'voice_note'}
        ]
    },
    {
        'user': {
            'user_name': 'Meera Nair',
            'user_email': 'meera.nair@example.com',
            'date_of_birth': '20th August 2001',
            'phone_number': '9740556677',
            'password': 'MeeraSparkle#21',
            'preferred_language': 'en'
        },
        'emergency_contacts': [
            {'name': 'Devika Nair', 'relationship': 'Mother', 'phone_number': '9740112233'}
        ],
        'locations': [
            {'location_name': 'St. Xavier College Library, North Wing, Mumbai', 'location_type': 'College'},
            {'location_name': 'Cafe Coffee Day, Churchgate Station', 'location_type': 'Cafe'}
        ],
        'saved_info': [
            {'title': 'Library Card Number', 'content': 'Card number is LIB-2024-889 kept in the front zipper of the blue backpack.', 'type': 'voice_note'},
            {'title': 'Audiobook Playlist', 'content': 'Audible playlist for Psychology Chapter 4 is bookmarked on phone.', 'type': 'voice_note'}
        ]
    }
]

def seed_data():
    for item in test_users_data:
        u = item['user']
        existing = query_db('SELECT user_id FROM USER WHERE user_email = %s;', (u['user_email'],), one=True)
        if existing:
            user_id = existing['user_id']
            print(f"User '{u['user_name']}' already exists with ID {user_id}.")
        else:
            res = client.post('/api/register', json=u)
            user_id = res.get_json()['user']['user_id']
            print(f"Registered new user '{u['user_name']}' with ID {user_id}.")

            for c in item['emergency_contacts']:
                client.post('/api/emergency-contacts', json={
                    'user_id': user_id,
                    'name': c['name'],
                    'relationship': c['relationship'],
                    'phone_number': c['phone_number']
                })

            for loc in item['locations']:
                client.post('/api/locations', json={
                    'user_id': user_id,
                    'location_name': loc['location_name'],
                    'location_type': loc['location_type'],
                    'address': loc['location_name']
                })

            for info in item['saved_info']:
                client.post('/api/saved-information', json={
                    'user_id': user_id,
                    'title': info['title'],
                    'content': info['content'],
                    'information_type': info['type']
                })

    print('\n' + '=' * 60)
    print('CURRENT DATABASE SUMMARY')
    print('=' * 60)
    tables = ['USER', 'USER_PREFERENCES', 'EMERGENCY_CONTACT', 'LOCATION', 'SAVED_INFORMATION']
    for t in tables:
        count = query_db(f'SELECT COUNT(*) as c FROM `{t}`;', one=True)['c']
        print(f'  {t:20}: {count} total rows')

if __name__ == '__main__':
    seed_data()
