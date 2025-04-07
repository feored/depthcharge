extends Node

var Weapons = {
	"Basic Driller":
	{
		"id": "Basic Driller",
		"remote": false,
		"timed": false,
		"speed": 50,
		"explodes_on_contact": true,
		"exploding_radius": 2,
		"carve_radius": 2,
		"homing": false,
		"cooldown": 3,
		"fire_sfx": Sfx.Track.FireDriller,
		"sprites": preload("res://weapons/Driller/sprites.tres"),
		"icon": preload("res://weapons/Driller/icon.png"),
	},
	"Remote Driller":
	{
		"id": "Remote Driller",
		"remote": true,
		"timed": false,
		"speed": 50,
		"explodes_on_contact": false,
		"exploding_radius": 3,
		"carve_radius": 2,
		"homing": false,
		"cooldown": 4,
		"fire_sfx": Sfx.Track.FireDriller,
		"sprites": preload("res://weapons/Remote Driller/sprites.tres"),
		"icon": preload("res://weapons/Remote Driller/icon.png"),
	},
	"Timed Driller":
	{
		"id": "Timed Driller",
		"remote": false,
		"timed": true,
		"max_time": 5,
		"speed": 50,
		"explodes_on_contact": false,
		"homing": false,
		"cooldown": 5,
		"exploding_radius": 4,
		"carve_radius": 2,
		"fire_sfx": Sfx.Track.FireDriller,
		"sprites": preload("res://weapons/Timed Driller/sprites.tres"),
		"icon": preload("res://weapons/Timed Driller/icon.png"),
	},
	"Seeker Driller":
	{
		"id": "Seeker Driller",
		"remote": false,
		"timed": false,
		"speed": 50,
		"homing": true,
		"homing_range": 200,
		"explodes_on_contact": true,
		"cooldown": 4,
		"exploding_radius": 2,
		"carve_radius": 1,
		"fire_sfx": Sfx.Track.FireDriller,
		"sprites": preload("res://weapons/Seeker Driller/sprites.tres"),
		"icon": preload("res://weapons/Seeker Driller/icon.png"),
	},
	"Penetrator":
	{
		"id": "Penetrator",
		"remote": false,
		"timed": true,
		"aim_speed": 20,
		"explodes_on_contact": true,
		"exploding_radius": 2,
		"carve_radius": 2,
		"fire_sfx": Sfx.Track.FireDriller,
		"sprites": preload("res://weapons/Driller/sprites.tres"),
	},

}

const FLAVOR = {
	"tectoid_escape_mayhem_1":
	{
		"chance": 0.5,
		"lines":
		[
			"Operator: One got away. That's okay. The perfect is the enemy of the good.",
			"Operator: Relax. You're new at this. Try not to get distracted by the mass death these things cause when they get loose.",
			"Operator: That was just a small one... should be fine.",
			"Operator: Can't win em' all.",
			"Operator: Maybe that one will just go destroy an empty city somewhere?",
			"Operator: ... minor setback.",
			"Operator: You'd think they'd put guns on that thing that faced forwards, right?",
			"Operator: ... remind me to check my insurance premiums later.",
			"Operator: You missed one. In case you didn't notice.",
			"Operator: Maybe that one's trying to negotiate? ... oh no. No it is not.",
			"Operator: Don't worry about that one. You got this.",
		]
	},
	"tectoid_escape_mayhem_2":
	{
		"chance": 0.5,
		"lines":
		[
			"Operator: Good to have at least a few loose for study... right?",
			"Operator: The army will probably get that one. Probably.",
			"Operator: We knew there'd be hiccups. Stay the course.",
			"Operator: Ludum Dare!",
			"Operator: I'm sure that one won't cause TOO much wanton destruction...",
			"Operator: Zigged when you should have zagged.",
			"Operator: I was gonna warn you about that one, but it looked like you had it. Noted for next time.",
			"Operator: Maybe they'll just get bored of destroying Earth and go back underground? Can't blame a gal for hoping.",
			"Operator: Don't mind that fire on the horizon. Everybody's just... having a big party.",
			"Operator: Okay. You've got the hang of this now, right? No more oopsies?",
			"Operator: Got those 'first time in an experimental sub-surface combat tank' jitters, huh?",
		]
	},
	"tectoid_escape_mayhem_3":
	{
		"chance": 0.5,
		"lines":
		[
			"Operator: Not great. Not terrible.",
			"Operator: Is everything okay? Are your controls inverted or something?",
			"Operator: Well, there goes my fantasy league. And most other peoples', too.",
			"Operator: That trigger thing on the joystick shoots your guns. Just making sure you were aware.",
			"Operator: Another one loose. Earth can't take much more of this.",
			"Operator: Christmas is cancelled. That's on you.",
			"Operator: I'm going to level with you. You're not doing great. Pick up the pace.",
			"Operator: I'm watching the feeds from the cities and... well just be thankful you don't have a TV in that thing.",
			"Operator: Sorry I wasn't watching. What just happened?",
			"Operator: That's... fine. You're... doing great. Keep it... up.",
			"Operator: If you had any secret moves to dramatically unveil now would be the time.",
		]
	},
	"tectoid_escape_mayhem_4":
	{
		"chance": 0.5,
		"lines":
		[
			"Operator: No pressure but... those things are sort of destroying our civilization. If you could stop them, that would be great.",
			"Operator: This is fine.",
			"Operator: ***! ****, ****, ****! ******* dirt-eating ****** *****!",
			"Operator: This can't be happening...",
			"Operator: ... even if we win... what's even left?",
			"Operator: Well... no reason to stay on my diet now, I guess. I'm going to step away and get some chips.",
			"Operator: So unrelated to anything but... did any of the brass tell you where the bunkers were? Asking for a friend.",
			"Operator: Let's think positively. We should view this as an *opportunity* to start civilization over from scratch. ",
			"Operator: Bright side: property values are at rock bottom. You think I might be able to afford a house now? You're right. Probably not.",
			"Operator: It's not over yet. Give em' hell!",
			"Operator: We're all gonna DIE!",
		]
	},
	"game_over":
	{
		"chance": 1,
		"lines":
		[
			"Operator: Well. That's it then.",
			"Operator: I... think I'll go outside for a bit...",
			"Operator: You blew it!",
			"Operator: I'm not mad at you. I'm just very disappointed.",
			"Operator: Okay... if this is an elaborate simulation you can stop now! Hello? Pull me out, please.",
			"Operator: I for one welcome our new Tectoid overlords.",
			"Operator: Maybe this won't be so bad. I always kind of wanted to live in a post-apocalypse.",
			"Operator: A TANK against all this? What were they THINKING?",
			"Operator: There's... nothing left...",
			"Operator: Tectoids 1, Earth 0.",
			"Operator: I had. So many sick days saved up. Lots of regrets right now.",
		]
	},
	"multi_kill":
	{
		"chance": 0.5,
		"lines":
		[
			"Operator: Boo-ya!",
			"Operator: Bet they didn't see THAT coming!",
			"Operator: There might be hope yet...",
			"Operator: Be honest. Was that on purpose? I won't tell anybody.",
			"Operator: Sick.",
			"Operator: Bet you can't do that again.",
			"Operator: Almost feel sorry for the little monsters...",
			"Operator: THAT. Keep doing THAT.",
			"Operator: Super Smokin' Style.",
			"Operator: They do NOT know who they're messing with, obviously.",
			"Operator: Keep it coming.",
		]
	},
	"black_spawn":
	{
		"chance": 1,
		"lines":
		[
			"Operator: One of those sneaky bugs is creeping around...",
			"Operator: This pattern... it's an AT Fiel...! No wait. It's a sneaky bug.",
			"Operator: Keep an eye on the radar. Sneaky bug just showed up.",
			"Operator: We're supposed to call them \"Code Blacks\". But I'm just gonna keep calling them sneaky bugs. Anyway there's one down there.",
			"Operator: Head on a swivel. Sneaky bug incoming.",
		]
	},
	"spawn_conqueror":
	{
		"chance": 1,
		"lines":
		[
			"Operator: The Conqueror cometh!",
			"Operator: Conqueror! Don't let it surface no matter what!",
			"Operator: Conqueror! It's over if that thing gets loose!",
			"Operator: It's a Conqueror... take it out at all costs.",
			"Operator: These readings... a Conqueror. We can't let it reach the surface.",
		]
	},
	"tower_unpowered":
	{
		"chance": 0.5,
		"lines":
		[
			"Operator: That radar tower is out of juice! Go over there and give it a jump!",
			"Operator: Showing a radar tower offline. You'll need to power it back up.",
			"Operator: I guess you're doing a 'no radar tower run'. No? Then go power it back up!",
			"Operator: You need all the GPR coverage you can get. Charge that tower back up.",
			"Operator: Empty batteries on that radar tower. Needs a recharge.",
		]
	},
	"10_sec_warning":
	{
		"chance": 0.5,
		"lines":
		[
			"Operator: Almost there!",
			"Operator: You can do it. Just a little longer.",
			"Operator: Scans show a break in their numbers soon. Keep at it.",
			"Operator: You're doing great. Just a little more.",
			"Operator: Looks like they're regrouping. Might have a break soon.",
			"Operator: 10 seconds until end of wave.",
			"Operator: Mop up the rest and let�s get you re-armed.",
			"Operator: Soon.",
			"Operator: Solid so far. Don't choke at the last minute. **** did I jinx it? Forget I said that.",
			"Operator: You've got the rest of this, right? I'm gonna go hit the head.",
			"Operator: They. Could. Go. All. The. WAY!",
		]
	},
	"round_over":
	{
		"chance": 1,
		"lines":
		[
			"Operator: Whew!",
			"Operator: Good job. But we're not done yet.",
			"Operator: We did it! Well, you did it but I offered valuable commentary.",
			"Operator: Light work.",
			"Operator: There might be some hope after all.",
			"Operator: Not reading any more signatures. The scope is clear.",
			"Operator: That's the last of them for now. Take a breather.",
			"Operator: Fell asleep at the console there for a second. What'd I miss?",
			"Operator: GOOOOOOOAL!",
			"Operator: Nailed it. Well done.",
			"Operator: Jeez, I thought they said this was supposed to be hard.",
		]
	},
}
