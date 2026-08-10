import sys
import os
import glob
import json
import argparse

parser = argparse.ArgumentParser()
parser.add_argument(
    "--base-config",
    type=str,
    help="Path to json file consist of base configuration of birdtray",
)

args = parser.parse_args()
if os.path.exists(args.base_config):
    with open(args.base_config, "r") as f:
        config = json.load(f)
else:
    config = {}

if 'accounts' not in config:
    config['accounts'] = []
globpat = os.path.join(
    os.path.expanduser("~/.thunderbird"), "*", "*Mail", "*", "INBOX.msf"
)
msf_files = glob.glob(globpat)
for msf in msf_files:
    config['accounts'].append(
        {
            "path": msf,
            # "color": "#FF0000",
        }
    )

config_path = os.path.join(
    os.getenv("XDG_CONFIG_HOME") or os.path.expanduser("~/.config"),
    "birdtray-config.json",
)
if os.path.exists(config_path):
    with open(config_path, "r") as f:
        before = json.load(f)
        if before == config:
            sys.exit(0)

os.makedirs(os.path.dirname(config_path), exist_ok=True)
with open(config_path, "w") as f:
    json.dump(config, f, indent=4)
