from game.common.stats import GameStats
from game.common.player import Player
from game.controllers.controller import Controller
from game.config import *

from collections import deque
import math
import random


class ActionController(Controller):
    def __init__(self):
        super().__init__()

        self.contract_list = list()


    def handle_actions(self, player):
        player_action = player.action

        #Call the appropriate method for this action
        if(player_action == ActionType.buy_gas):
            raise NotImplementedError("ActionType buy_gas hasn't been implemented yet")

        elif(player_action == ActionType.choose_speed):
            raise NotImplementedError("ActionType choose_speed hasn't been implemented yet")

        elif(player_action == ActionType.select_contract):
            #Checks if contract_list is empty. If so, we have a problem
            if(len(self.contract_list) == 0): raise ValueError("Contract list cannot be empty")

            #Selects the contract given in the player.action.contract_index
            self.select_contract(player)
        elif(player_action == ActionType.select_route):
            #Moves the player to the node given in the action_parameter
            self.move(player, player_action.action_parameter)

        elif(player_action == ActionType.upgrade):
            self.buy_gas(player)

    # Action Methods ---------------------------------------------------------
    def move(self, player, road):
        self.current_location = player.truck.current_node
        time_taken = 0
        for route in self.current_location.connections:
            if route is road:
                player.truck.current_node = route.city_2
                time_taken = road.length / player.truck.get_current_speed()
        player.time -= time_taken

    # Retrieve by index and store in Player, then clear the list
    def select_contract(self, player):
        player.active_contract = self.contract_list[int(player.action.contract_index)]
        self.contract_list.clear()

    def buy_gas(self, player):
        gasPrice = round(random.uniform(1, 5), 2)  # gas price per percent
        if(player.truck.current_node.node_type is NodeType.city and player.truck.money > 0):
            percentRemain = player.truck.max_gas - round(player.truck.gas, 2)
            maxPercent = round((player.truck.money / gasPrice) / 100, 2)
            if(percentRemain < maxPercent):
                player.truck.money -= percentRemain * gasPrice
                player.truck.gas = player.truck.max_gas
            else:
                player.truck.money = 0
                player.truck.money += maxPercent

    # End of Action Methods --------------------------------------------------
    