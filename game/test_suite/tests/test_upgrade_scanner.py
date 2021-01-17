# This is a quick example test file to show you the basics.
# Always remember to add the proper details to the __init__.py file in the 'tests' folder
# to insure your tests are run.

from game.common import stats
from game.utils import helpers
import unittest
from game.common.player import Player
from game.common.TrUpgrades.police_scanner import PoliceScanner
from game.controllers.action_controller import ActionController
from game.common.enums import *


# Your test class is a subclass of unittest.Testcase, this is important
class TestUpgradeScanner(unittest.TestCase):

    # This method is used to set up anything you wish to test prior to every test method below.
    def setUp(self):
        self.myPlayer = Player(12, "Sean")
        self.myPlayer.truck.money = 1000000
        self.actionCont = ActionController()

    # Test methods should always start with the word 'test'
    def test_upgrade_one_level(self):
        self.myPlayer.truck.addons.level = 0
        self.myPlayer.truck.money = 10000
        expectedCash = 10000 - stats.GameStats.costs_and_effectiveness[ObjectType.policeScanner]['cost'][1]
        self.actionCont.upgrade_level(self.myPlayer, ObjectType.policeScanner)
        self.assertEqual(self.myPlayer.truck.addons.level,
                         ScannerLevel.level_one)
        self.assertEqual(expectedCash, self.myPlayer.truck.money)
        self.assertTrue(isinstance(self.myPlayer.truck.addons, PoliceScanner))

    def test_upgrade_two_level(self):
        self.myPlayer.truck.addons.level = 0
        self.myPlayer.truck.money = 10000
        expectedCash = 10000 - \
            stats.GameStats.costs_and_effectiveness[ObjectType.policeScanner]['cost'][1] - \
             stats.GameStats.costs_and_effectiveness[ObjectType.policeScanner]['cost'][2]
        self.actionCont.upgrade_level(self.myPlayer, ObjectType.policeScanner)
        self.actionCont.upgrade_level(self.myPlayer, ObjectType.policeScanner)
        self.assertEqual(self.myPlayer.truck.addons.level,
                         ScannerLevel.level_two)
        self.assertEqual(expectedCash, self.myPlayer.truck.money)
        self.assertTrue(isinstance(self.myPlayer.truck.addons, PoliceScanner))

    def test_upgrade_beyond_allowable(self):
        self.myPlayer.truck.addons.level = 0
        self.myPlayer.truck.money = 10000
        expectedCash = 10000 - \
            helpers.addTogetherDictValues( stats.GameStats.costs_and_effectiveness[ObjectType.policeScanner]['cost'])
        self.actionCont.upgrade_level(self.myPlayer, ObjectType.policeScanner)
        self.actionCont.upgrade_level(self.myPlayer, ObjectType.policeScanner)
        self.actionCont.upgrade_level(self.myPlayer, ObjectType.policeScanner)
        self.actionCont.upgrade_level(self.myPlayer, ObjectType.policeScanner)
        self.actionCont.upgrade_level(self.myPlayer, ObjectType.policeScanner)
        self.assertEqual(self.myPlayer.truck.addons.level,
                         ScannerLevel.level_three)
        self.assertEqual(self.myPlayer.truck.money, expectedCash)
        self.assertTrue(isinstance(self.myPlayer.truck.addons, PoliceScanner))

    def test_no_money(self):
        self.myPlayer.truck.addons.level = 0
        self.myPlayer.truck.money = 10
        self.actionCont.upgrade_level(self.myPlayer, ObjectType.policeScanner)
        self.assertEqual(self.myPlayer.truck.addons.level,
                         ScannerLevel.level_zero)
        self.assertEqual(self.myPlayer.truck.money, 10)

    # This is just the very basics of how to set up a test file
    # For more info: https://docs.python.org/3/library/unittest.html


if __name__ == '__main__':
    unittest.main
