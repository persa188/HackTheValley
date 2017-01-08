###Submitting a Vote

path=/api/vote  
method=POST (Application/JSON)
give eventid and username and option id of the option you want to vote for. If you get 200 back you're ok
```e.x.
{
  "username":"daniel",
  "optionid":1,
  "eventid":9
}
```

###Getting Vote History
path=/api/votehistory  
method=GET  
give the username of the user and then you get their vote history back in json form
e.x.
```
url/api/votehistory?username=daniel
```
result
```
{
  "results": [
    {
      "eventid": 2,
      "optionid": 2
    },
    {
      "eventid": 9,
      "optionid": 3
    }
  ]
}
```
