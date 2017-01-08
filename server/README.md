# project-x REST API
TEST USERNAME & PASS = test123:pass
###Latest Update
- lots of changes will update readme soon

### Python Dependencies
@see requirements.txt

###Usage

####Launching the server
in the shell type
```bash
python ./app.py
```
make sure port 5000 is open, the server will be listening on localhost:5000/api and you can make request using curl in the terminal or from the app.

####Login query
Login requests will be done by POST request to the server as follows where the sample username and password in this case is brandon & brandon123 respectivley.
```bash
curl --data "username=brandon&passwd=brandon123" localost:5000/api/login
```
- returns 200 if Success
- 40x if not found
- 30x if error

###Register query
Register a user similarly to how you would make a login request a sample curl query is below.
```bash
curl --data "username=brandoniqa&passwd=brandon123" localost:5000/api/registeruser
```
- returns 30x error if user exists already
- returns 20x if success

###Adding an Event
- make a POST request to localhost:5000/api/events
- the request should contain raw "application/json" in the body formatted as below
```
{
  "name": name of event
  "descr": decription of event
  //more params will be added when a db schema is agreed upon
}
```

###Getting Events
**Getting All events:**  
- make a GET request to /api/events

**Getting Specific events:**  
- make a GET request to /api/events/(event name)  

**Upcoming Features to implement:**  
the following are to be implemented, but depend heavily on how our db schema ends up looking
- getting top n events sorted by various metadata params such as data/popularity/odds
