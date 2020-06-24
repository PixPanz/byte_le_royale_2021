from game.common.game_object import GameObject
from game.common.enums import *
from game.common.road import *
from game.common.map import Map

class Node(GameObject):
    
    #Name is the key for this node in the graph it must be unique 
    def __init__(self, name):
        super().__init__()
        self.object_type = ObjectType.node
        self.city_name = name
        self.location_type = LocationType.none
        self.connections = list()
        # registers this object to the graph with city_name as the key
        Map.cities[self.city_name] = self
    
    def to_json(self):
        data = super().to_json()
        data['location_type'] = self.location_type
        data['city_name'] = self.city_name
        data['connections'] = self.connections
        return data

    def from_json(self, data):
        super().from_json(data)
        self.location_type = data['location_type']
        self.city_name = data['city_name']
        self.connections = data['connections']
        Map.cities[self.city_name] = self

    # this method connects two cities together and generates a road object
    def Connect(self,cityToConnect, roadName):
        road = Road(roadName,self.city_name,cityToConnect.city_name)
        self.connections.append(road.road_name)
        return road



    
    
   