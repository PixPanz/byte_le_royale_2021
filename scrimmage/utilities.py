
IP = '134.129.91.187'
PORT = 5007
BUFFER_SIZE = 10000

REGISTER_COMMANDS = ['register', 'r']
SUBMIT_COMMANDS = ['submit', 's']
VIEW_STATS_COMMANDS = ['view stats', 'view', 'v']
LEADERBOARD_COMMANDS = ['leaderboard', 'l']


def file_to_binary(filename):
    res = None
    with open(filename, 'rb') as f:
        res = f.read()

    return res


def binary_to_file(filename, ba):
    with open(filename, 'wb') as f:
        for b in ba:
            f.write(b)
