import requests
import json
import urllib3
import os

class ClientUtils:
    def __init__(self):
        urllib3.disable_warnings()
        self.IP = 'https://134.129.91.223:8000/api/'
        self.PORT = 8000
        self.path_to_public = "server/certs/cert.pem"

    def get_team_types(self):
        resp = requests.get(self.IP + "get_team_types", verify=self.path_to_public)
        resp.raise_for_status()
        return json.loads(resp.content)

    def get_unis(self):
        resp = requests.get(self.IP + "get_unis", verify=self.path_to_public)
        resp.raise_for_status()
        return json.loads(resp.content)

    def register(self, reg_data):
        resp = requests.post(self.IP + "register", reg_data, verify=self.path_to_public)
        resp.raise_for_status()
        return resp

    def submit_file(self, file, vid):
        data = {"file": file, "vid": vid}
        resp = requests.post(self.IP + "submit", json=data, verify=self.path_to_public)
        resp.raise_for_status()
        return resp

    def submit_file(self, file, vid):
        data = {"file": file, "vid": vid}
        resp = requests.post(self.IP + "submit", json=data, verify=self.path_to_public)
        resp.raise_for_status()
        return resp

    def get_leaderboard(self, include_inelligible, sub_id):
        data = {"include_inelligible": include_inelligible, "sub_id": sub_id}
        resp = requests.post(self.IP + "get_leaderboard", json=data, verify=self.path_to_public)
        resp.raise_for_status()
        jsn = json.loads(resp.content)
        print("The following is the leaderboard for eligible contestants")
        self.to_table(jsn)

    def get_team_score_over_time(self, vid):
        resp = requests.post(
            self.IP + "get_team_score_over_time", json={"vid": vid}, verify=self.path_to_public)
        resp.raise_for_status()
        jsn = json.loads(resp.content)
        print("The following is your team's performance in each group run")
        self.to_table(jsn)

    def get_submission_stats(self, vid):
        resp = requests.post(
            self.IP + "get_submission_stats", json={"vid": vid}, verify=self.path_to_public)
        resp.raise_for_status()
        return json.loads(resp.content)

    
    def get_runs_for_submission(self, vid, subid):
        resp = requests.post(
            self.IP + "get_runs_for_submission", json={"vid": vid, "submissionid": subid}, verify=self.path_to_public)
        resp.raise_for_status()
        jsn = json.loads(resp.content)
        self.to_table(jsn)

    
    def get_team_runs_for_group_run(self, vid, groupid):
        resp = requests.post(
            self.IP + "get_team_runs_for_group_run", json={"vid": vid, "groupid": groupid}, verify=self.path_to_public)
        resp.raise_for_status()
        jsn = json.loads(resp.content)
        self.to_table(jsn)

    def get_group_runs(self, vid):
        resp = requests.post(
            self.IP + "get_group_runs", json={"vid": vid}, verify=self.path_to_public)
        resp.raise_for_status()
        jsn = json.loads(resp.content)
        self.to_table(jsn)

    def get_submissions(self, vid):
        resp = requests.post(
            self.IP + "get_submissions_for_team", json={"vid": vid}, verify=self.path_to_public)
        resp.raise_for_status()
        jsn = json.loads(resp.content)
        self.to_table(jsn)


    def get_seed_for_run(self, vid, runid):
        resp = requests.post(
            self.IP + "get_seed_from_run", json={"vid": vid, "runid" : runid}, verify=self.path_to_public)
        resp.raise_for_status()
        jsn = json.loads(resp.content)
        if jsn is None:
            print("Bad Vid and RunID combination (probably)")
        else:
            with open(f"./seed_for_run_{runid}.json", "w") as fl:
                fl.write(jsn)
            with open(f"./logs/game_map.json", "w") as fl:
                fl.write(jsn)
            print(f"Seed for run {runid} has been written to game_map.json. A copy has also been made at {os.path.realpath(fl.name)}")

    def determine_stats(self, data):
        max_score = -1
        sum = 0
        for row in data:
            sum += row['score']
            if row['score'] > max_score:
                max_score = row['score']
        print(f"Your max score was {max_score}")
        print(f"Your average score was {sum / len(data)}")

        

    def get_longest_cell_in_cols(self, json, json_atribs):
        col_longest_length = {}
        for key in json_atribs:
            col_longest_length[key] = (len(key))
        for col in json_atribs:
            for row in json:
                if len(str(row[col])) > col_longest_length[col]:
                    col_longest_length[col] = len(row[col])
        return col_longest_length

    def get_seperator_line(self, col_longest_length, padding):
        rtn = ""
        for key in col_longest_length:
            rtn += "+" + ("-" * (col_longest_length[key] + padding))
        return rtn + "+"

    def to_table(self, json):
        try:
            padding = 4
            json_atribs = json[0].keys()
            col_longest_length = self.get_longest_cell_in_cols(
                json, json_atribs)
            line_seperator = self.get_seperator_line(
                col_longest_length, padding)
            row_format = ""
            for key in json_atribs:
                row_format += "|{:^" + \
                    str(col_longest_length[key] + padding) + "}"
            row_format += "|"
            print(line_seperator)
            print(row_format.format(*json_atribs))
            for row in json:
                print(line_seperator)
                print(row_format.format(*row.values()))
            print(line_seperator)
        except:
            print(
                "Something went wrong. Maybe there isn't data for what you're looking for")
