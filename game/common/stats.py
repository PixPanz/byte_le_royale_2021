from game.common.enums import Region


class GameStats:
    default_road_length = 100

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

    # cost in doollaridoos to upgrade a police scanner
    scanner_upgrade_cost = {
        ScannerLevel.level_zero: 0,
        ScannerLevel.level_one: 300,
        ScannerLevel.level_two: 900,
        ScannerLevel.level_three: 2000
    }

    # error range provided by each scanner
    sensor_ranges = {
        ScannerLevel.level_zero: 100,
        ScannerLevel.level_one: 50,
        ScannerLevel.level_two: 20,
        ScannerLevel.level_three: 1
    }

    game_max_time = 10000

    player_starting_money = 1000

    truck_starting_gas = 1

    truck_starting_max_gas = 1
