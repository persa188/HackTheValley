###Submitting a Vote

path=/api/vote  
method=POST  
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
