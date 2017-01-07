#!flask/bin/python

from flask import Flask, jsonify, abort, make_response, request
from flask_pymongo import PyMongo
import sqlite3
import md5

#TODO: update secret, add SALT
#TODO: synchronize responses to match standard resps
#TODO: documentation
#TODO: add auth, need to implement a user class for @req login tags

db = 'app.db'
secret = "FRRAND"
app = Flask(__name__)

app.config['MONGO_DBNAME'] = 'projectx'
app.config['MONGO_URI'] = 'mongodb://localhost:27017/appdb'

mongo = PyMongo(app)

@app.route('/api/login', methods=['POST'])
def login():
	#get from post request and hash passwd
	#TODO: switch to sha256 & add salt
	username = request.form['username']
	passwd = md5.new(secret + request.form['passwd']).hexdigest()

	#sql query
	conn = sqlite3.connect(db)
	cursor = conn.cursor()
	cursor.execute("SELECT count(*) FROM users WHERE uname=? and passwd=?", (username, passwd))
	data = cursor.fetchone()

	#handle response
	if data[0] == 0:
		conn.close()
		return jsonify(msg="user not found", response=404)
	elif (data[0] == 1):
		conn.close()
		return jsonify(msg="Login Success", response=200)
	else:
		conn.close()
		return jsonify(msg="Login Fail - Invalid Credentials", response=301, data=data)


#a psuedo register user method
@app.route('/api/registeruser', methods=['POST'])
def create_user():
	try:
		uname = request.form['username']
		passwd = md5.new(secret + request.form['passwd']).hexdigest()
	except:
		#missing params
		abort(400)

	if not uname or not passwd:
		#empty parm(s)
		return jsonify(msg="one or more parameters are empty, pls fix", status=401)

	#sql portion
	conn = sqlite3.connect(db)
	cursor = conn.cursor()

	#TODO: switch to SHA2/3 + SALT and ensure user doesn't already exist
	#check if exists first
	cursor.execute("SELECT count(*) FROM users WHERE uname=? and passwd=?", (uname, passwd))
	data = cursor.fetchone()

	if data[0] != 0:
		conn.close()
		return jsonify(msg="invalid request, user exists", status=302)

	#add the user
	conn = sqlite3.connect(db)
	cursor = conn.cursor()
	cursor.execute("INSERT INTO users VALUES (?, ?)", (uname, passwd))
	conn.commit()
	conn.close()

	#database.add(user) here, if already exists return somthing else 400?401?205?
	return jsonify(msg="user registered succesfully, not fully impl", status=201) #success

#Add an event to the db
@app.route('/api/events', methods=['POST'])
def add_post():
	event = mongo.db.events
	#get params
	name = request.json['name']
	descr = request.json['descr']

	#check if exists, throw appropriate resp
	#could use upsert, however in the spirit of resful post only for insert
	if not mongo.db.events.find({'name': name}).count() > 0:
		return jsonify(status=300, msg="item with name already exists")

	#add to db
	event_id = event.insert({'name': name, 'descr': descr})
	new_event = event.find_one({'_id': event_id })

	output = {'name' : new_event['name'], 'distance' : new_event['descr']}

  	return jsonify({'result' : output})

#get all events from the db
@app.route('/api/events', methods=['GET'])
def get_all_events():
	events = mongo.db.events
	output = []
  	for s in events.find():
		output.append({'name' : s['name'], 'descr' : s['descr']})
  	return jsonify({'result' : output})

#get a specific event from db
@app.route('/api/events/', methods=['GET'])
def get_one_event(name):
	"""
	@param name name of event to get
	@return json event details
	@see db schema for expected format
	"""
	events = mongo.db.events
	s = events.find_one({'name': name})
	if s:
		output = {'name': s['name'], 'descr': s['descr']}
	else:
		#throw err here to be safe
		return jsonify(status=300, msg="no such item exists")
	return jsonify({'result': output})

#TODO: add a get top n events, add dates and other metadata to events
# for supporting sort queries (like get most recent n events etc.)

#better error msg for json reqs
@app.errorhandler(404)
def not_found(error):
	return make_response(jsonify({'error': 'Not Found'}), 404)


if __name__ == '__main__':
	app.run(debug=True)
