import csv
states_uts = set(
    [
        "Andaman and Nicobar Islands",
        "Andhra Pradesh",
        "Arunachal Pradesh",
        "Assam",
        "Bihar",
        "Chandigarh",
        "Chhattisgarh",
        "Dadra and Nagar Haveli",
        "Daman and Diu",
        "Delhi",
        "Goa",
        "Gujarat",
        "Haryana",
        "Himachal Pradesh",
        "India",
        "Jammu and Kashmir",
        "Jharkhand",
        "Karnataka",
        "Kerala",
        "Lakshadweep",
        "Madhya Pradesh",
        "Maharashtra",
        "Manipur",
        "Meghalaya",
        "Mizoram",
        "Nagaland",
        "Odisha",
        "Pondicherry",
        "Punjab",
        "Rajasthan",
        "Sikkim",
        "Tamil Nadu",
        "Telangana",
        "Tripura",
        "Uttar Pradesh",
        "Uttarakhand",
        "West Bengal",
    ]
)


with open("input/gini.txt", "r") as file:
    lines = file.readlines()
    lines = [line.rstrip() for line in lines]


def remove_headers(lines):
    skipping = True
    new_lines = []
    for line in lines:
        if "(Table A1 Continued)" in line or "Source" in line:
            skipping = True
        if not skipping:
            new_lines.append(line)
        if "NSS" in line:
            skipping = False
    return new_lines


def fix_multilines(lines):
    new_lines = []
    for line in lines:
        if len(new_lines) and not is_data_line(new_lines[-1]):
            new_lines[-1] = new_lines[-1] + " " + line
        else:
            new_lines.append(line)
    return new_lines

def add_states(lines):
    new_lines = []
    queue = []
    state_lines = []
    for line in lines:
        if is_district_line(line):
            queue.append(line)
        if is_state_ut_line(line) or get_text(line) in states_uts:
            state_ut = get_text(line)
            state_lines.append(line)
            for queued_line in queue:
                queued_line = queued_line.rstrip() + " " + state_ut
                new_lines.append(queued_line)
            queue.clear()
    return new_lines, state_lines

def format_lines(lines):
    split_lines = []
    for line in lines:
        split = line.split()
        split_line = []
        for word in split:
            if not word.isalpha() or not len(split_line) or (len(split_line) and not split_line[-1].replace(" ", "").isalpha()):
                split_line.append(word.replace(",", ""))
            else:
                split_line[-1] = split_line[-1] + " " + word
        if not split_line[0].replace(" ", "").isalpha():
            split_line.pop(0)
        split_lines.append(split_line)

    dropped = 0
    dicts = []
    for split_line in split_lines:
        if len(split_line) < 9:
            dropped += 1
            continue
        line_dict = {}
        if split_line[-1].replace(" ", "").isalpha():
            line_dict["district"] = split_line[0]
            line_dict["state"] = split_line[-1]
            line_dict["gini"] = split_line[8]
        else:
            line_dict["state"] = split_line[0]
            line_dict["gini"] = split_line[8] if len(split_line) >= 12 else split_line[5]
        dicts.append(line_dict)
    return dicts, dropped

def get_text(line):
    return line.strip("\n,.1234567890 ")

def is_state_ut_line(line):
    return line.split()[0].isalpha()

def is_data_line(line):
    return not line.split()[-1].isalpha()

def is_district_line(line):
    return line.split()[0].isnumeric()

lines = remove_headers(lines)
lines = fix_multilines(lines)
lines, states_uts_lines = add_states(lines)
# with open("output/gini_cleaned.txt", "w") as file:
#     for line in lines:
#         file.write(line + "\n")

dicts_districts, dropped_districts = format_lines(lines)
with open("output/districts_gini.csv", "w", newline="") as file:
    writer = csv.DictWriter(file, fieldnames=["state", "district", "gini"])
    writer.writeheader()
    for line in dicts_districts:
        writer.writerow(line)
print("Dropped", dropped_districts, "districts without Gini data.")

dicts_states_uts, dropped_states_uts = format_lines(states_uts_lines)
with open("output/states_uts_gini.csv", "w", newline="") as file:
    writer = csv.DictWriter(file, fieldnames=["state", "gini"])
    writer.writeheader()
    for line in dicts_states_uts:
        writer.writerow(line)
print("Dropped", dropped_states_uts, "states or UTs without Gini data.")