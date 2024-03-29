==============
Add On Objects
==============

Add-On object occupies the addons attribute of your truck. You can only have one Add-On object at a time.

The Police Scanner Object
#########################

The police scanner object helps you evade the cops. It will reduce the damage and time taken from the police event.
Referenced as:

.. code-block:: python

    ObjectType.policeScanner

The levels are below

=====  ================== =======
Level  Negation modifier   Cost
=====  ================== =======
0       0.1                5400 
1       0.2                10800
2       0.35               16200
3       0.5                21600
=====  ================== =======

The GPS Object
########################

GPS will help re-route you away from traffic. It will reduce the damage and time taken from the traffic event.
Referenced as:

.. code-block:: python

    ObjectType.GPS

The levels are below

=====  ================== =======
Level  Negation modifier   Cost
=====  ================== =======
0       0.1                5400 
1       0.2                10800
2       0.35               16200
3       0.5                21600
=====  ================== =======


The Rabbits Foot Object
########################

The Rabbit's foot will bring you good luck in the event a disaster occuring. 
It will minorly reduce incoming damage from all event types. This bonus will stack additively with your other damage reduction bonuses.
Referenced as:

.. code-block:: python

    ObjectType.rabbitFoot

The levels are below

=====  ================== =======
Level  Negation modifier   Cost
=====  ================== =======
0       0.025              5400 
1       0.05               10800
2       0.1                16200
3       0.15               21600
=====  ================== =======
