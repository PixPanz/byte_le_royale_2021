from game.common.stats import GameStats
from game.common.enums import EventType, ObjectType
from game.common.illegal_contract import IllegalContract
from game.controllers.controller import Controller
from game.common.TrUpgrades.police_scanner import PoliceScanner
import random
import math


class EventController(Controller):

    def __init__(self):
        super().__init__()

    def trigger_event(self, road, player, truck):
        # Picks random event type from those possible on given road
        chosen_event_type = random.choices(list(GameStats.possible_event_types[road.road_type].keys()), weights=GameStats.possible_event_types[road.road_type].values(), k=1)[0]
        mods = self.negation(truck, chosen_event_type)
        current_contract = player.truck.get_active_contract()
        # Deal damage based on event
        player.truck.health -= GameStats.event_type_damage[chosen_event_type] * (1 - mods['HealthMod']) * GameStats.contract_stats['difficulty_modifier'][current_contract.difficulty]
        # Reduce remaining time based on event
        player.time -= GameStats.event_type_time[chosen_event_type] * (1 - mods['DamageMod']) * GameStats.contract_stats['difficulty_modifier'][current_contract.difficulty]
        return chosen_event_type

    def event_chance(self, road, player, truck):
        if (truck.get_current_speed() > 50):
            chance = .0295*((truck.get_current_speed() - 50)**2) + 25.612
        else:
            chance = 15*(math.log10(truck.get_current_speed()+1))
        happens = random.choices([True, False], weights=[chance, 100-chance],k=1)[0]
        event = []
        if happens:
            event.append(self.trigger_event(road, player, truck))
        else:
            event.append(EventType.none)
        event.append(self.police_event(player))
        return event
    
    def police_event(self, player): 
        if isinstance(player.truck.active_contract, IllegalContract):
            mitigation = (
                    GameStats.costs_and_effectiveness[ObjectType.policeScanner]['effectiveness'][player.truck.addons.level] 
                    if isinstance(player.truck.addons, PoliceScanner) else 0
            )
            level = player.truck.active_contract.level
            risk = GameStats.illegal_contract_stats['risk'][level]*(1-mitigation)
            caught = random.choices([True, False], weights=[risk, 1-risk], k=1)[0]
            if caught:
                if player.truck.money - player.truck.active_contract.penalties['money_penalty'] >= 0:
                    player.truck.money -= player.truck.active_contract.penalties['money_penalty']
                else:
                    player.truck.money = 0
                player.time -= player.truck.active_contract.penalties['time_penalty']
                player.truck.active_contract = None
            return caught
        else:
            return False
    
    def calculateMod(self, obj, event):
        health = GameStats.costs_and_effectiveness[obj.object_type]['effectiveness'][obj.level]
        time = GameStats.costs_and_effectiveness[obj.object_type]['effectiveness'][obj.level]
        return (health, time)

    def calculateTireMod(self, obj, event):
        health = GameStats.costs_and_effectiveness[ObjectType.tires]['effectiveness'][obj]
        time =  GameStats.costs_and_effectiveness[ObjectType.tires]['effectiveness'][obj]
        return (health, time)

    def negation(self, truck, event):
        mods = {'HealthMod': 0, 'DamageMod': 0}
        objs = [truck.addons, truck.body]
        try:
            for obj in objs:
                if event in GameStats.negations[obj.object_type]:
                    potentialMod = self.calculateMod(obj, event)
                    mods['HealthMod'] += potentialMod[0]
                    mods['DamageMod'] += potentialMod[1]
            # The logic for tires is slightly different
            if event in GameStats.negations[truck.tires]:
                potentialMod = self.calculateTireMod(truck.tires, event)
                mods['HealthMod'] = max(potentialMod[0], mods['HealthMod'])
                mods['DamageMod'] = max(potentialMod[1], mods['DamageMod'])
            return mods
        except:
            return {'HealthMod': 0, 'DamageMod': 0}

    def handle_actions(self, client):
        return
