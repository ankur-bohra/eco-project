import pandas as pd
import json
pd.set_option('display.max_rows', None)

GWQ_NAME = "hardnesstotal"
INFER_GINI = True  # Infer Gini for districts broken into multiple districts

# Merge GWQ with NSDPs
gwq = pd.read_csv("input/GWQ.csv")
gwq["state"] = gwq["state"].str.title()
gwq["district"] = gwq["district"].str.title()

# Find duplicate (state, district) rows in GWQ
dupes = gwq[gwq.duplicated(subset=["state", "dyid"], keep=False)][["state", "district"]].drop_duplicates()
print("Districts duplicated in GWQ.csv:")
print(dupes.reset_index(drop=True))

# Remove duplicate rows for amiguity
gwq.drop_duplicates(subset=["state", "dyid"], inplace=True, keep=False)
dupes = gwq[gwq.duplicated(subset=["state", "dyid"], keep=False)][["state", "district"]].drop_duplicates()

nsdps = pd.read_csv("input/NSDPs.csv")
nsdps = pd.melt(nsdps, id_vars=["YEAR"], var_name="state", value_name="nsdp")
nsdps.rename(columns={"YEAR": "year"}, inplace=True)
nsdps["state"] = nsdps["state"].str.title()

nsdps.to_csv("output/NSDPs.csv")

# print(set(gwq['state']) - set(nsdps['state']))
state_mapping = {
    "Puducherry": "Pondicherry",
    "Tamilnadu": "Tamil Nadu",
    "Jammu & Kashmir": "Jammu And Kashmir",
    "Orissa": "Odisha",
    "Andaman & Nicobar Islands": "Andaman And Nicobar Islands",
}
gwq["state"] = gwq["state"].replace(state_mapping)
nsdps["state"] = nsdps["state"].replace(state_mapping)
# nsdps.drop(nsdps.loc[(nsdps["year"] < 2000) | (nsdps["year"] > 2018)].index, inplace=True)
# print(set(gwq['state']) - set(nsdps['state']))

gwq.drop(
    columns=(
        set(gwq.columns)
        - {"country", "state", "district", "year", "dyid", GWQ_NAME}
    ),
    inplace=True,
)
gwq_nsdp = gwq.merge(nsdps, left_on=["state", "year"], right_on=["state", "year"], how="outer")
gwq_nsdp.sort_values(by=["state", "district", "year"], inplace=True)
gwq_nsdp.to_csv("output/gwq_nsdp.csv", index=False)

# print("Missingess in NSDPs:")
# print(gwq_nsdp[gwq_nsdp["nsdp"].isnull()][["state", "year"]].drop_duplicates().reset_index(drop=True))
# print()
# print("Missingness in hardnesstotal:")
# print(gwq_nsdp[gwq_nsdp[GWQ_NAME].isnull()][["state", "district", "year"]].drop_duplicates().reset_index(drop=True))
# print()
# print("Missingness in hardnesstotal (by state):")
# print(gwq_nsdp[gwq_nsdp[GWQ_NAME].isnull()][["state", "district", "year"]].drop_duplicates()["state"].value_counts())
# print()

# Merge Gini with NSDPs
gini = pd.read_csv("output/districts_gini.csv")
gini["state"] = gini["state"].str.title()
gini["district"] = gini["district"].str.title()
# gwq_nsdp=gwq_nsdp[gwq_nsdp['year']==2010]
# print(set(gwq_nsdp['state']) - set(gini['state']))

# gini_temp = gini.rename(columns={"district": "district_gini", "state": "state_gini"})
# join = gwq_nsdp.merge(
#     gini_temp,
#     left_on=["state", "district"],
#     right_on=["state_gini", "district_gini"],
#     how="left",
# )
# misses = join[join["gini"].isnull()][["state", "district"]].drop_duplicates()
# print(misses)

with open("data/district_mapping.json", "r") as file:
    DISTRICT_MAPPING = json.load(file)
alias_dupes = []
renamed_old = []
for state, districts in DISTRICT_MAPPING.items():
    for district, aliases in districts.items():
        if type(aliases) == str:
            aliases = [aliases]
        if not INFER_GINI:
            aliases = [aliases[0]]  # Spelling only
        # Add duplicate rows for each row for each alias into gini 
        renamed_old.append(district)
        for alias in aliases:
            # print(state, district, alias)
            alias_dupes.append(pd.DataFrame({
                'state': state,
                'district': alias,
                'gini': gini.loc[(gini['state'] == state) & (gini['district'] == district)]['gini']
            }))
gini.drop(gini[gini['district'].isin(renamed_old)].index, inplace=True)
gini = pd.concat([gini] + alias_dupes)

gini_temp = gini.rename(columns={"district": "district_gini", "state": "state_gini"})
join = gwq_nsdp.merge(
    gini_temp,
    left_on=["state", "district"],
    right_on=["state_gini", "district_gini"],
    how="left",
)
misses = join[join["gini"].isnull()][["state", "district"]].drop_duplicates()
# Count the number of unique state-district pairs in the GWQ-NSDP dataset
# and compare it with the number of unique state-district pairs in the merged dataset
# to see if any were missed
print(f"Unable to merge {misses.shape[0]} of {gwq_nsdp[['state', 'district']].drop_duplicates().shape[0]} from gwq_nsdp JOIN gini:")
print(misses.reset_index())

merged = gwq_nsdp.merge(gini, on=["state", "district"], how="outer")
merged.sort_values(by=["state", "district", "year"], inplace=True)
merged.to_csv("output/gini_gwq_nsdp.csv", index=False)