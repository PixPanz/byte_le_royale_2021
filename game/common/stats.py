from game.common.enums import *


class GameStats:
    default_road_length = 100

    road_length_maximum_deviation = 20

    region_reward_modifier = {
        Region.grass_lands: .5,
        Region.nord_dakotia: .6,
        Region.mobave_desert: .7,
        Region.mount_vroom: .8,
        Region.lobslantis: .8,
        Region.tropical_cop_land: .9,
    }

    region_difficulty_modifier = {
        Region.grass_lands: .5,
        Region.nord_dakotia: .6,
        Region.mobave_desert: .7,
        Region.mount_vroom: .8,
        Region.lobslantis: .8,
        Region.tropical_cop_land: .9,
    }

    # objects that can occupy the body slot
    body_objects = [
        ObjectType.tank,
        ObjectType.headlights,
        ObjectType.sentryGun
    ]

    # objects that can occupy the addon slot
    addonObjects = [
        ObjectType.policeScanner,
        ObjectType.rabbitFoot,
        ObjectType.GPS
    ]

    tireObjects = [
        TireType.tire_econ,
        TireType.tire_normal,
        TireType.tire_sticky
    ]

    # Tire types are in the enums. Not sure why I did that lol.

    # cost in doollaridoos to upgrade a police scanner
    costs_and_effectiveness = {
        ObjectType.policeScanner: {
            'cost': {
                ScannerLevel.level_zero: 0,
                ScannerLevel.level_one: 300,
                ScannerLevel.level_two: 900,
                ScannerLevel.level_three: 2000
            },

            # error range provided by each scanner
            'effectiveness': {
                ScannerLevel.level_zero: .1,
                ScannerLevel.level_one: .2,
                ScannerLevel.level_two: .3,
                ScannerLevel.level_three: .6
            }
        },

        ObjectType.tank: {
            'cost': {
                TankLevel.level_zero: 10,
                TankLevel.level_one: 300,
                TankLevel.level_two: 900,
                TankLevel.level_three: 2000
            },

            'effectiveness': {
                TankLevel.level_zero: 1,
                TankLevel.level_one: 1.5,
                TankLevel.level_two: 2,
                TankLevel.level_three: 4
            }
        },

        ObjectType.tires: {

            "effectiveness": {
                TireType.tire_econ: .5,
                TireType.tire_normal: .6,
                TireType.tire_sticky: .8
            },

            "fuel_efficiency": {
                TireType.tire_econ: 1.5,
                TireType.tire_normal: 1,
                TireType.tire_sticky: .5
            }
        },


        ObjectType.headlights: {
            "cost": {
                HeadlightLevel.level_zero: 10,
                HeadlightLevel.level_one: 50,
                HeadlightLevel.level_two: 100,
                HeadlightLevel.level_three: 300
            },

            "effectiveness": {
                HeadlightLevel.level_zero: .1,
                HeadlightLevel.level_one: .3,
                HeadlightLevel.level_two: .7,
                HeadlightLevel.level_three: .9
            }
        },

        ObjectType.sentryGun: {
            "cost": {
                SentryGunLevel.level_zero: 10,
                SentryGunLevel.level_one: 50,
                SentryGunLevel.level_two: 100,
                SentryGunLevel.level_three: 300
            },
            "effectiveness": {
                SentryGunLevel.level_zero: .1,
                SentryGunLevel.level_one: .3,
                SentryGunLevel.level_two: .6,
                SentryGunLevel.level_three: .8
            }

        },

        ObjectType.rabbitFoot: {
            "cost": {
                RabbitFootLevel.level_zero: 10,
                RabbitFootLevel.level_one: 20,
                RabbitFootLevel.level_two: 40,
                RabbitFootLevel.level_three: 80
            },

            "effectiveness": {
                RabbitFootLevel.level_zero: .1,
                RabbitFootLevel.level_one: .2,
                RabbitFootLevel.level_two: .25,
                RabbitFootLevel.level_three: .27
            }

        },

        ObjectType.GPS: {
            "cost": {
                GPSLevel.level_zero: 100,
                GPSLevel.level_one: 200,
                GPSLevel.level_two: 700,
                GPSLevel.level_three: 1400
            },

            "effectiveness": {
                GPSLevel.level_zero: .33,
                GPSLevel.level_one: .5,
                GPSLevel.level_two: .58,
                GPSLevel.level_three: .65
            }
        }
    }

    road_type_length_modifier = {
        RoadType.mountain_road: 1,
        RoadType.forest_road: 1,
        RoadType.tundra_road: 1.5,
        RoadType.city_road: 1.5,
        RoadType.highway: 2,
        RoadType.interstate: 2
    }

    possible_event_types = {
        RoadType.mountain_road: [EventType.rock_slide, EventType.animal_in_road, EventType.icy_road, EventType.police, EventType.none],
        RoadType.forest_road: [EventType.animal_in_road, EventType.police, EventType.rock_slide, EventType.icy_road, EventType.none],
        RoadType.tundra_road: [EventType.icy_road, EventType.police, EventType.rock_slide, EventType.none],
        RoadType.city_road: [EventType.bandits, EventType.police, EventType.traffic, EventType.none],
        RoadType.highway: [EventType.police, EventType.traffic, EventType.none],
        RoadType.interstate: [EventType.traffic, EventType.police, EventType.none]
    }

    event_weights = {
        # Order for corresponding event type listed above list
        # Mountain order: rock slide, animal in road, icy road, police, none
        RoadType.mountain_road: [40, 30, 20, 10, 0],
        # Forest order: animal in road, police, rock slide, icy road, none
        RoadType.forest_road: [40, 30, 20, 10, 0],
        # Tundra order: icy road, police, rock slide, none
        RoadType.tundra_road: [50, 33, 17, 0],
        # City order: bandits, police, traffic, none
        RoadType.city_road: [50, 33, 17, 0],
        # Highway order: police, traffic, none
        RoadType.highway: [67, 33, 0],
        # Interstate order: traffic, police, none
        RoadType.interstate: [67, 33, 0]
    }

    animal_total = 0
    bandit_total = 0
    icy_total = 0
    police_total = 0
    rockslide_total = 0
    traffic_total = 0
    for i in possible_event_types:
        for j in possible_event_types[i]:
            if possible_event_types[i][j] == EventType.animal_in_road:
                animal_total += event_weights[i][j]
            elif possible_event_types[i][j] == EventType.bandits:
                bandit_total += event_weights[i][j]
            elif possible_event_types[i][j] == EventType.icy_road:
                icy_total += event_weights[i][j]
            elif possible_event_types[i][j] == EventType.police:
                police_total += event_weights[i][j]
            elif possible_event_types[i][j] == EventType.rock_slide:
                rockslide_total += event_weights[i][j]
            elif possible_event_types[i][j] == EventType.traffic:
                traffic_total += event_weights[i][j]
    animal_chance = animal_total/2400
    bandit_chance = bandit_total/2400
    icy_chance = icy_total/2400
    police_chance = police_total/2400
    rockslide_chance = rockslide_total/2400
    traffic_chance = traffic_total/2400

    event_type_damage = {
        EventType.animal_in_road: 1/animal_chance,
        EventType.bandits: 1/bandit_chance,
        EventType.icy_road: 1/icy_chance,
        EventType.police: 1/police_chance,
        EventType.rock_slide: 1/rockslide_chance,
        EventType.traffic: 1/traffic_chance,
        EventType.none: 0
    }

    event_type_time = {
        EventType.animal_in_road: animal_total / 20,
        EventType.bandits: bandit_total / 20,
        EventType.icy_road: icy_total / 20,
        EventType.police: police_total / 20,
        EventType.rock_slide: rockslide_total / 20,
        EventType.traffic: traffic_total / 20,
        EventType.none: 0
    }

    negations = {

        ObjectType.headlights: [
            EventType.animal_in_road,
            EventType.traffic,
            EventType.police,
            EventType.rock_slide
        ],

        ObjectType.sentryGun: [
            EventType.bandits,
            EventType.police,
            EventType.animal_in_road
        ],

        ObjectType.GPS: [
            EventType.bandits,
            EventType.traffic,
            EventType.rock_slide,
            EventType.police
        ],

        ObjectType.tank: [

        ],

        ObjectType.policeScanner: [
            EventType.police,
            EventType.bandits,
            EventType.rock_slide
        ],

        ObjectType.rabbitFoot: [
            EventType.animal_in_road,
            EventType.bandits,
            EventType.icy_road,
            EventType.police,
            EventType.rock_slide,
            EventType.traffic
        ],

        TireType.tire_sticky: [
            EventType.animal_in_road,
            EventType.icy_road,
            EventType.police,
            EventType.rock_slide,
        ],
        TireType.tire_normal: [
            EventType.animal_in_road,
            EventType.icy_road,
            EventType.police,
            EventType.rock_slide,
        ],
        TireType.tire_econ: [
            EventType.animal_in_road,
            EventType.icy_road,
            EventType.police,
            EventType.rock_slide,
        ]
    }

    base_event_probability = [25, 75]

    game_max_time = 10000

    player_starting_money = 1000

    truck_starting_gas = 1

    truck_starting_max_gas = 1

    truck_starting_mpg = 8

    tire_switch_cost = 300

    truck_starting_health = 50

    road_length_variance = .2

    contract_node_count = {
        'short': 8,
        'medium': 14,
        'long': 21
    }

    contract_rewards = {
        'easy': 200,
        'medium': 500,
        'hard': 1100
    }
