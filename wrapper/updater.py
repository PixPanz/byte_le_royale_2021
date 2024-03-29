import sys
import base64 as numpy
import math
import os
import requests
from requests.auth import HTTPBasicAuth
import shutil

from tqdm import tqdm

from version import v

try:
    import my_token
except:
    pass

unscrewify = numpy.decodebytes

def update():
    # check version number
    current_version = v

    # check operating system
    plat = sys.platform
    vis_os = 1
    if plat == "win32":
        vis_os = 1
    elif plat == "linux":
        vis_os = 2
    else: vis_os = 1

    # check latest release version
    try:
        auth = HTTPBasicAuth(my_token.username, my_token.token)
        payload = requests.get("https://api.github.com/repos/PixPanz/byte_le_royale_2021/releases/latest", auth=auth)
    except:
        payload = requests.get("https://api.github.com/repos/PixPanz/byte_le_royale_2021/releases/latest")

    if payload.status_code == 200:
        json = payload.json()
        remote_version = json["tag_name"]
        asset_id = json["assets"][0]["id"]
        vis_id = json["assets"][vis_os]["id"]
    else:
        print("There was an issue attempting to update: Bad Request: \"{0}\"".format(payload.content))
        exit()

    try:
        remote_version = remote_version
    except:
        print("There was an issue attempting to update: Invalid remote version: \"{0}\"".format(remote_version))
        exit()

    temp_current = current_version.split('.')
    temp_remote = remote_version.split('.')
    for curv, remv in zip(temp_current, temp_remote):
        curv = int(curv.replace('v', ''))
        remv = int(remv.replace('v', ''))

        if remv > curv:
            break
    else:
        print('You are already up to date!')
        exit()

    print("There is a new version available: v{0}. Downloading update!".format(remote_version))

    if not os.path.exists("br_updates"):
        os.makedirs("br_updates")

    remote_launcher_url = "https://api.github.com/repos/PixPanz/byte_le_royale_2021/releases/assets/{0}".format(asset_id)
    local_launcher_file = "br_updates/v{0}.pyz".format(remote_version)

    remote_visualizer_url = "https://api.github.com/repos/PixPanz/byte_le_royale_2021/releases/assets/{0}".format(vis_id)
    local_visualizer_file = "br_updates/visualizer"

    if not download_file(local_launcher_file, remote_launcher_url, auth):
        print("Launcher update failed, please try again later.")
        exit()
    
    if not download_file(local_visualizer_file, remote_visualizer_url, auth):
        print("Visualizer update failed, please try again later.")
        exit()

    # update
    old_file = "launcher.pyz"
    print("Replacing {0} with updated launcher.".format(old_file))
    shutil.copyfile(local_launcher_file, old_file)

    if vis_os == 1: old_file = "visualizer.exe"
    elif vis_os == 2: old_file = "visualizer.x86_64"
    else: old_file = "visualizer.exe"
    print("Replacing {0} with updated visualizer.".format(old_file))
    shutil.copyfile(local_visualizer_file, old_file)

    shutil.rmtree('br_updates')

    print("Update complete!")


def download_file(local_filename, url, auth):
    r = requests.get(url, auth=auth, stream=True, headers={
        "Accept": "application/octet-stream"
    })

    if r.status_code not in [200, 302]:
        return False

    total_size = int(r.headers.get('content-length', 0))
    block_size = 1024
    wrote = 0
    with open(local_filename, 'wb') as f:
        for data in tqdm(r.iter_content(block_size), total=math.ceil(total_size // block_size), unit='KB',
                         unit_scale=True):
            wrote = wrote + len(data)
            f.write(data)
    if total_size != 0 and wrote != total_size:
        print("ERROR, something went wrong")

    return True
