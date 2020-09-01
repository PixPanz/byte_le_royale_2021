from game.common.enums import *

from game.common.contract import Contract


class Action:
    def __init__(self):
        self.object_type = ObjectType.action
        self._chosen_action = None
        self.contract_index = None
        self.__destination = None

    def set_action(self, action, contractIndex = None):
        self._chosen_action = action
        if action == ActionType.select_contract:
            self.contract_index = contractIndex
        else:
            self.contract_index = None
    
    def get_destination(self):
        return self.__destination

    def set_destination (self, truck, destination):
        if not isinstance(destination, ObjectType.node):
            return
        if not isinstance(truck, ObjectType.truck):
            return
        self.current_location = truck.current_node
        for road in self.current_location.connections:
            if road.city_2 == destination.city_name:
                truck.current_node = destination
        self.__destination = destination

    def to_json(self):
        data = dict()

        data['object_type'] = self.object_type
        data['chosen_action'] = self._chosen_action
        data['destination'] = self.__destination

        return data

    def from_json(self, data):
        self.object_type = data['object_type']
        self._chosen_action = data['chosen_action']
        self.__destination = data['destination']

    def __str__(self):
        outstring = ''
        outstring += f'Example Action: {self._chosen_action}\n'

        return outstring
