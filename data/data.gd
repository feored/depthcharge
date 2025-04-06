extends Node

const Weapons = {
	"Basic Driller":
	{
		"id": "Basic Driller",
		"remote": false,
		"charge_release_to_fire": false,
		"speed": 50,
		"explodes_on_contact": true,
		"exploding_radius": 5,
		"sprites": preload("res://weapons/Driller/sprites.tres"),
	},
	"Remote Driller":
	{
		"id": "Remote Driller",
		"remote": true,
		"charge_release_to_fire": false,
		"speed": 50,
		"explodes_on_contact": false,
		"exploding_radius": 2,
		"sprites": preload("res://weapons/Remote Driller/sprites.tres"),
	},
	"Timed Driller":
	{
		"id": "Timed Driller",
		"remote": false,
		"charge_release_to_fire": true,
		"speed": 50,
		"explodes_on_contact": false,
		"exploding_radius": 4
	},
	"Seeker Driller":
	{
		"id": "Seeker Driller",
		"remote": false,
		"charge_release_to_fire": false,
		"speed": 50,
		"explodes_on_contact": true,
		"exploding_radius": 2
	}
}
