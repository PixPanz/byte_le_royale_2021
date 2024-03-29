import uuid
from game.common.action import Action
from game.common.game_object import GameObject
from game.common.enums import *
from game.common.contract import Contract
from game.common.truck import Truck
from game.common.node import Node
from game.common.stats import GameStats


class Player(GameObject):
    # truck initialized with placeholder
    def __init__(self, code=None, team_name=None, action=None, truck=Truck()):
        super().__init__()
        self.object_type = ObjectType.player
        self.functional = True
        self.error = None
        self.team_name = team_name
        self.code = code
        self.action = action
        self.truck = truck
        self.time = GameStats.game_max_time

    def to_json(self):
        data = super().to_json()

        data['functional'] = self.functional
        data['error'] = self.error
        data['team_name'] = self.team_name
        data['time'] = self.time
        data['action'] = self.action.to_json() if self.action is not None else dict()
        data['truck'] = self.truck.to_json()
        return data

    def from_json(self, data):
        super().from_json(data)
        self.functional = data['functional']
        self.error = data['error']
        self.team_name = data['team_name']
        self.time = data['time']
        act = Action()
        act.from_json(data['action']) if data['action'] is not None else None 
        self.action = act
        truck = Truck()
        truck.from_json(data['truck'])
        self.truck = truck

    def __str__(self):
        p = f"""ID: {self.id}
            Team name: {self.team_name}
            Action: {self.action}
            Time: {self.time}
            """
        return p
