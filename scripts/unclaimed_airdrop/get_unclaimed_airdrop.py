### This script calculates the amount of the airdrop that is unclaimed,
### including the 20% given to accounts who haven't done any of the claiming activities.
### This lets us reason accurately about how much has been unclaimed.

import json

# path to file output by 
# mokitad export-derive-balances [state export] [output-filepath]
filepath = "balances_breakdown.json"
# read file
with open(filepath, 'r') as myfile:
    data=myfile.read()

obj = json.loads(data)
accts = obj['accounts']

# get unclaimed moki amount
def get_base_unclaimed_amount(base_account):
    unclaimed = base_account['unclaimed']
    unclaimed_amt = 0
    if len(unclaimed) != 0:
        unclaimed_amt = int(unclaimed[0]['amount'])
    return unclaimed_amt

# get liquid moki amount
def get_liquid_moki_balance(base_account):
    liquid_moki = 0
    if len(base_account['balance']) != 0:
        for p in base_account['balance']:
            if p['denom'] == "umoki":
                liquid_moki = int(p['amount'])
    return liquid_moki

total_unclaimed_excluding_base_twenty = 0
total_unclaimed_including_base_twenty = 0

for k in accts.keys():
    base = accts[k]
    unclaimed_moki = get_base_unclaimed_amount(base)
    liquid_moki = get_liquid_moki_balance(base)
    staked = int(base['staked']) != 0
    bonded = len(base['bonded']) != 0

    total_unclaimed_excluding_base_twenty += unclaimed_moki
    total_unclaimed_including_base_twenty += unclaimed_moki

    # We want to check if a user is inactive thus far, and if so include their liquid 20%.
    # We do this by checking if they have no staked, no bonded
    # and if their liquid balance = .25 * unclaimed bal
    if unclaimed_moki == 0:
        continue

    if not (staked or bonded):
        # to account for rounding error, check equality with some margin.
        if abs((unclaimed_moki // 4) - liquid_moki) < 1000000:
            total_unclaimed_including_base_twenty += liquid_moki

print("unclaimed non-already-distributed balance", total_unclaimed_excluding_base_twenty / (10**6), "moki")
print("unclaimed & inactive", total_unclaimed_including_base_twenty/ (10**6), "moki")
print("simple prediction for unclaimed and inactive (div by .8)", (total_unclaimed_excluding_base_twenty / .8)/ (10**6), "moki")