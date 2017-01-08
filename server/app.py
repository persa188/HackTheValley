#!/usr/bin/env python
import os
import json
from flask import Flask, abort, request, jsonify, g, url_for
from flask.ext.sqlalchemy import SQLAlchemy
from flask.ext.httpauth import HTTPBasicAuth
from passlib.apps import custom_app_context as pwd_context
from itsdangerous import (TimedJSONWebSignatureSerializer
                          as Serializer, BadSignature, SignatureExpired)

# initialization
app = Flask(__name__)
app.config['SECRET_KEY'] = 'the quick brown fox jumps over the lazy dog'
app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///db.sqlite'
app.config['SQLALCHEMY_COMMIT_ON_TEARDOWN'] = True

# extensions
db = SQLAlchemy(app)
auth = HTTPBasicAuth()

#the SQL Alchemy way of modelling SQL, this is for user
class User(db.Model):
    __tablename__ = 'users'
    id = db.Column(db.Integer, primary_key=True)
    username = db.Column(db.String(32), index=True)
    password_hash = db.Column(db.String(64))

    def hash_password(self, password):
        """
        hash the password using the builtin library that is based on sha2/3
        """
        self.password_hash = pwd_context.encrypt(password)

    def verify_password(self, password):
        """
        verify the passwd
        """
        return pwd_context.verify(password, self.password_hash)

    def generate_auth_token(self, expiration=1200000):
        """
        generate a token that user can use for auth, valid for exp time
        """
        s = Serializer(app.config['SECRET_KEY'], expires_in=expiration)
        return s.dumps({'id': self.id})

    @staticmethod
    def verify_auth_token(token):
        """
        verify token, reuturn none if bad or expired else
        return the user
        """
        s = Serializer(app.config['SECRET_KEY'])
        try:
            data = s.loads(token)
        except SignatureExpired:
            return None    # valid token, but expired
        except BadSignature:
            return None    # invalid token
        user = User.query.get(data['id'])
        return user

class Profile(db.Model):
    __tablename__ = 'profile'
    userid = db.Column(db.Integer, primary_key=True)
    address = db.Column(db.String(64))
    age = db.Column(db.Integer)
    meta = db.Column(db.String(64))

class Event(db.Model):
    __tablename__ = 'events'
    id = db.Column(db.Integer, primary_key=True, autoincrement=True)
    eventname = db.Column(db.String(64), index=True)
    starttime= db.Column(db.Integer)
    endtime = db.Column(db.Integer)
    description = db.Column(db.String(64))
    photo = db.Column(db.String(64))

#Voting Class
class Vote(db.Model):
    __tablename__ = 'votes'
    username = db.Column(db.String(32), primary_key=True)
    eventid = db.Column(db.Integer, primary_key=True)
    optionid = db.Column(db.Integer)

class Have(db.Model):
    __tablename__ = 'have'
    eventid = db.Column(db.Integer, primary_key=True)
    optionid = db.Column(db.Integer, primary_key=True)

class Options(db.Model):
    __tablename__ = 'options'
    id = db.Column(db.Integer, primary_key=True, autoincrement=True)
    value = db.Column(db.String(64))

@auth.verify_password
def verify_password(username_or_token, password):
    # first try to authenticate by token
    user = User.verify_auth_token(username_or_token)
    if not user:
        # try to authenticate with username/password
        user = User.query.filter_by(username=username_or_token).first()
        if not user or not user.verify_password(password):
            return False
    g.user = user
    return True


@app.route('/api/users', methods=['POST'])
def new_user():
    username = request.json.get('username')
    password = request.json.get('password')
    if username is None or password is None:
        abort(400)    # missing arguments
    if User.query.filter_by(username=username).first() is not None:
        abort(400)    # existing user
    user = User(username=username)
    user.hash_password(password)
    db.session.add(user)
    db.session.commit()
    #create a matching profile
    profile = Profile(userid=user.id)
    db.session.add(profile)
    db.session.commit()
    return (jsonify({'username': user.username}), 201,
            {'Location': url_for('get_user', id=user.id, _external=True)})


@app.route('/api/users/<int:id>')
def get_user(id):
    user = User.query.get(id)
    if not user:
        abort(400)
    return jsonify({'username': user.username})

@app.route('/')
def defa():
    return "hi"

@app.route('/api/token')
@auth.login_required
def get_auth_token():
    token = g.user.generate_auth_token(600)
    return jsonify({'token': token.decode('ascii'), 'duration': 600})


@app.route('/api/addevent', methods = ['POST'])
#@auth.login_required
def add_event():
    eventname= request.json.get('eventname')
    description= request.json.get('description')
    starttime=request.json.get("starttime")
    endtime=request.json.get("endtime")
    options=request.json.get("options")
    phot=request.json.get("photo")

    if (eventname is None or description is None or starttime is None
        or endtime is None or options is None):
        abort(400)    # missing arguments

    event = Event(description=description, eventname=eventname, starttime=1, endtime=1, photo=photo)
    db.session.add(event)
    db.session.commit()

    #add to has and create options
    for s in options:
        create_options(s, event.id)

    return jsonify({"status": 200, "response": "event with created with id: "+ str(event.id)})


@app.route('/api/deleteevent/<int:id>', methods = ['DELETE'])
#@auth.login_required
def remove_event(id):
    event = Event.query.get(id)
    if not event:
        abort(400)
    Event.query.filter_by(id=id).delete()
    #Remove Links
    links = Have.query.filter_by(eventid=9)
    for res in links.all():
        Options.query.filter_by(id=res.optionid).delete()
    links.delete()
    db.session.commit()
    return jsonify({"status":200})


@app.route('/api/votehistory', methods = ['GET'])
def get_vote_history():
    res = []
    username = request.args['username']
    votes = Vote.query.filter_by(username=username).all()
    for v in votes:
        res.append({"eventid":v.eventid, "optionid":v.optionid})
    return jsonify({"results":res})

@app.route('/api/vote/', methods = ['POST'])
def vote_event():
    #get params
    eventid=request.json.get('eventid')
    username=request.json.get('username')
    optionid=request.json.get('optionid')

    if (eventid is None) or (username is None) or (optionid is None):
        abort(400) #missing params
    else:
        vote = Vote(username=username, eventid=eventid, optionid=optionid)
        #validation handled via triggers
        #cast vote
        try:
            db.session.add(vote)
            db.session.commit()
            return jsonify({"status":200, "response":"vote cast successfully"})
        except:
            abort(400)#most likely the vote already exists

def create_options(value, eventid):
    #missing params
    if (value is None):
        abort(400)
    #Create new Event
    option = Options(value=value)
    db.session.add(option)
    db.session.commit()

    #Create Link between Event and Option
    link = Have(optionid=option.id, eventid=eventid)
    db.session.add(link)
    db.session.commit()


@app.route('/api/events', methods=['GET'])
def get_events():
    res = []
    events = Event.query.all()
    for e in events:
        res.append({"eventid": e.id, "eventname": e.eventname, "description": e.description, "options": get_options_h(e.id)})
    return jsonify({"events": res})

def get_options_h(eid):
    '''helper fn'''
    res = []
    have = Have.query.filter_by(eventid=eid).all()
    for s in have:
        res.append({"optionid":s.optionid,"value":Options.query.get(s.optionid).value})
    return res

@app.route('/api/event', methods=['GET'])
def get_event():
    reid= request.args['id']
    events = Event.query.filter_by(id=reid).first()
    return jsonify({"status": 200, "event":{"eventid":events.id, "eventname":events.eventname, "description":events.description, "photo":events.photo, "options": get_options_h(events.id)}})

@app.route('/api/user/setmeta', methods = ['PUT'])
def set_metadata():
    #get user
    userid = request.json.get('userid')
    profile = Profile.query.get(userid)
    if (profile is None):
        abort(400)
    #get params
    meta = str(request.json.get('meta'))
    #update info
    profile.meta = meta
    #db.session.update(user)
    db.session.commit()
    return jsonify({"status": 200, "response": "Metadata updated successfully"})


@app.route('/api/user/getmeta', methods = ['GET'])
def get_metadata():
    #get user
    userid = request.args['id']
    profile = Profile.query.filter_by(userid=userid).first()
    if (profile is None):
        abort(400)
    #return info
    return jsonify({"status": 200, "meta": profile.meta})


@app.route('/api/user/editprofile', methods = ['PUT'])
def edit_profile():
    #get user
    userid = request.json.get('userid')
    profile = Profile.query.get(userid)
    if (profile is None):
        abort(400)
    #get params
    meta = str(request.json.get('meta'))
    #update info
    profile.address = request.json.get('address', profile.address)
    profile.age = request.json.get('age', profile.age)
    profile.meta = str(request.json.get('meta', profile.meta))
    #db.session.update(user)
    db.session.commit()
    return jsonify({"status": 200, "response": "Profile updated successfully"})


@app.route('/api/user/getprofile', methods = ['GET'])
def get_profile():
    #get user
    userid = request.args['id']
    profile = Profile.query.filter_by(userid=userid).first()
    if (profile is None):
        abort(400)
    #return info
    return jsonify({"status": 200, userid:{"address":profile.address, "age":profile.eventname, "description":profile.description}})

@app.route('/api/checkifvoted', methods = ['GET'])
def checkifvoted():
    username = request.args['username']
    eventid = request.args['eventid']

    if username is None or eventid is None:
        abort(400)

    try:
        vote = Vote.query.filter_by(username=username, eventid=eventid).first()
        return jsonify(status=200, optionid=vote.optionid, resp="did vote")
    except:
        return jsonify(status=200, optionid=-1, resp="did not vote")


@app.route('/api/user/geteventstat', methods = ['GET'])
def get_stat():
    #get user
    res = {}
    eventid = request.args['id']
    options = Have.query.filter_by(eventid=eventid).all()
    for opt in options:
        res[opt.id] = Vote.query.filter_by(eventid=eventid).count()
    #return info
    return jsonify({"status": 200, "results": res})


if __name__ == '__main__':
    if not os.path.exists('db.sqlite'):
        db.create_all()
    app.run(debug=True)
