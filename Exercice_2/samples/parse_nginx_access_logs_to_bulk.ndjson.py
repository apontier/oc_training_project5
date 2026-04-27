import re
import json
from datetime import datetime

log_pattern = re.compile(
    r'(\S+) \S+ \S+ \[([^\]]+)\] "(\S+) (\S+)(?: (\S+))?" (\d{3}) (\d+|-) "(.*?)" "(.*?)"'
)

def convert_timestamp(ts):
    # Convertit : 30/Jun/2024:15:33:00 +0000
    # en ISO 8601 : 2024-06-30T15:33:00+00:00
    return datetime.strptime(ts, "%d/%b/%Y:%H:%M:%S %z").isoformat()


def parse_line(line):
    match = log_pattern.match(line)
    if not match:
        return None

    ip, timestamp, method, path, protocol, status, bytes_, referrer, user_agent = match.groups()

    return {
        "ip": ip,
        "@timestamp": convert_timestamp(timestamp),
        "method": method,
        "path": path,
        "protocol": protocol,
        "status": int(status),
        "bytes": int(bytes_) if bytes_.isdigit() else 0,
        "referrer": referrer,
        "user_agent": user_agent,
        "plain_log": f"{ip} - - [{timestamp}] \"{method} {path} {protocol}\" {status} {bytes_} \"{referrer}\" \"{user_agent}\""
    }

input_file = "nginx-access.log"  # Remplacez par le chemin de votre fichier de logs
output_file = "bulk.ndjson"  # Le fichier de sortie au format bulk.ndjson

with open(input_file, "r") as f, open(output_file, "w") as out:
    for line in f:
        parsed = parse_line(line)
        if not parsed:
            continue

        # Bulk API Elasticsearch format
        out.write(json.dumps({"index": {"_index": "nginx-access"}}) + "\n")
        out.write(json.dumps(parsed) + "\n")

print("Done → bulk.ndjson generated")