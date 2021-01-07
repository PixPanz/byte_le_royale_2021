# This is a quick example test file to show you the basics.
# Always remember to add the proper details to the __init__.py file in the 'tests' folder
# to insure your tests are run.
from game.common import stats
from game.utils import helpers
import unittest
from game.common.player import Player
from game.common.node import Node
from game.common.node import Road
from game.controllers.action_controller import ActionController
from game.common.enums import *
from game.common.TrUpgrades.gps import GPS


# Your test class is a subclass of unittest.Testcase, this is important
class TestActionController(unittest.TestCase):

    # This method is used to set up anything you wish to test prior to every test method below.
    def setUp(self):
        self.myPlayer = Player(12, "Sean")
        self.myPlayer.money = 10000
        self.actionCont = ActionController()
        next = Node('Second', [Road('Bruh', RoadType.highway)])
        self.myPlayer.truck.current_node = Node('First', [Road('Lane', RoadType.city_road), Road('Bruh', RoadType.forest_road)],next)

    # Test methods should always start with the word 'test'
    def test_valid_move(self):
        breakpoint()
        self.actionCont.move(self.myPlayer, self.myPlayer.truck.current_node.roads[0] )
        

 

    # This is just the very basics of how to set up a test file
    # For more info: https://docs.python.org/3/library/unittest.html


if __name__ == '__main__':
    unittest.main
