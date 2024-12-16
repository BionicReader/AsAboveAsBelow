extends Node2D
class_name State

var change_state
var animation: AnimatedSprite2D  # Explicitly declare the animation variable with its type
@onready var main_body = $MainBody
@onready var die = $Die
@onready var shoot = $Shoot
@onready var attack = $Attack
@onready var shootbody = $ShootBody

var persistent_state

func setup(change_state_param, animation_param: AnimatedSprite2D, persistent_state_param):
	self.change_state = change_state_param
	self.animation = animation_param  # Now correctly assigns the animation
	self.persistent_state = persistent_state_param
