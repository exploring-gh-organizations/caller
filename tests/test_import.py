import requests

def test_requests_get():
    response = requests.get("https://httpbin.org/get")
    assert response.status_code == 200
