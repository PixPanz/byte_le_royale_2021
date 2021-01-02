from game.common.stats import GameStats
from game.common.player import Player
from game.controllers.controller import Controller
from game.config import *
from game.controllers import event_controller

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
            self.buy_gas(player)

        elif(player_action == ActionType.choose_speed):
            #This is an ActionType because the user client cannot directly influence truck values. 
            player.truck.set_current_speed(player.action_parameter)

        elif(player_action == ActionType.select_contract):
            #Checks if contract_list is empty. If so, we have a problem
            if(len(self.contract_list) == 0): raise ValueError("Contract list cannot be empty")

            #Selects the contract given in the player.action.contract_index
            self.select_contract(player)
            
        elif(player_action == ActionType.select_route):
            #Moves the player to the node given in the action_parameter
            self.move(player, player_action.action_parameter)

        elif(player_action == ActionType.upgrade):
            raise NotImplementedError("ActionType upgrade hasn't been implemented yet")        

    # Action Methods ---------------------------------------------------------
    def move(self, player, road):
        self.current_location = player.truck.current_node
        time_taken = 0
        for route in self.current_location.roads:
            if route is road: #May need to be redone
                player.truck.current_node = self.current_location.next_node
                event_controller.trigger_event(road, player, player.truck)
                time_taken = road.length / player.truck.get_current_speed()
        gas_used = (road.length/GameStats.truck_starting_mpg)/(GameStats.truck_starting_max_gas*100)
        player.truck.gas -= gas_used
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
    