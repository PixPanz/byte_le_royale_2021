from game.common.game_object import GameObject
from game.common.enums import *
from game.common.road import *
from game.common.node import Node
from game.common.TrUpgrades.police_scanner import PoliceScanner
from game.common.TrUpgrades.BodyObjects.tank import Tank
from game.common.stats import GameStats
from game.common.contract import Contract

# Probably need to add some extra stuff
class Truck(GameObject):

    def __init__(self, node = None):
        super().__init__()
        self.object_type = ObjectType.truck
        self.current_node = node
        self.contract_list = []
        self.active_contract = None
        self.body = Tank()
        self.addons = PoliceScanner()
        self.tires = TireType.tire_normal
        self.speed = 50
        self.health = GameStats.truck_starting_health

    def get_city_contracts(self):
        return self.contract_list

    def get_active_contract(self):
        return self.active_contract

    def get_current_speed(self):
        return self.speed

    def set_current_speed(self, speed):
        if speed < 1:
            speed = 1
        self.speed = speed

    def to_json(self):
        data = super().to_json()
        node = self.current_node.to_json() if self.current_node is not None else None
        data['current_node'] = node
        data['contract_list'] = {contract.name: contract.to_json() for contract in self.contract_list}
        data['active_contract'] = self.active_contract.to_json() if self.active_contract is not None else None
        data['speed'] = self.speed
        data['health'] = self.health
        data['body'] = self.body.to_json()
        data['addons'] = self.addons.to_json()
        data['tires'] = self.tires
        return data

    def from_json(self, data):
        super().from_json(data)
        node = Node('temp')
        self.current_node = node.from_json(data['current_node'])
        temp = Contract()
        for contract in data['contract_list'].values():
            self.contract_list.append(temp.from_json(contract))
        self.active_contract = temp.from_json(data['active_contract'])
        self.current_node = data['current_node']
        self.speed = data['speed']
        self.health = data['health']
        self.body = data['body']
        self.addons = data['addons']
        self.tires = data['tires']

    def __str__(self):
        contracts_string = []
        for contract in self.contract_list:
            contracts_string.append(str(contract))
        p = f"""Current Node: {self.current_node.city_name}
            Contract List: {str(contracts_string)}
            Contract: {str(self.active_contract)}
            Gas: {self.body.current_gas}
            Max Gas: {self.body.max_gas}
            Speed: {self.speed}
            Health: {self.health}
            """
        return p
