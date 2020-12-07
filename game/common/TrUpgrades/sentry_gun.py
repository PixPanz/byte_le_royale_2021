from game.common.TrUpgrades.baseUpgradeObject import baseUpgradeObject
from game.common.enums import *
from game.common.stats import *


class SentryGun(baseUpgradeObject):
    def __init__(self):
        super().__init__(ObjectType.sentryGun,SentryGunLevel.level_zero)
        self.MissleLauncher = False

    def to_json(self):
        data = super().to_json()
        data['missleLauncher'] = self.MissleLauncher
        return data

    def from_json(self, data):
        super().from_json(data)
        self.MissleLauncher = data['missleLauncher']

    def __str__(self):
        p = super.__str__
        p += f"""missle Launcher on?: {self.missleLauncher}"""
        return p
