import requests

url = 'http://127.0.0.1:5000/correct'
data = {'text': 'This are a test sentence with errors.'}
response = requests.post(url, json=data)
print(response.json())
