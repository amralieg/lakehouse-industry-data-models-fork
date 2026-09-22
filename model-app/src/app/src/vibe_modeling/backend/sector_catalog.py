"""Standard sector catalog for seeding the sectors table (ADR D-047).

This is a SNAPSHOT of the runner's authoritative ``SECTOR_MAP``
(``modelling_agent/runner/industry-sectors/_generate.py`` — 10 sectors / 40
industries, the source of the agent's Volume folder structure). It is captured here
because the app cannot read the runner at boot; an Agent-side task tracks
upstreaming a shared source so this snapshot can be regenerated rather than
hand-maintained. Revise this list if the runner's SECTOR_MAP changes.

``SECTOR_CATALOG`` seeds the ``sectors`` table (the taxonomy top level).
``SECTOR_INDUSTRY_MAP`` (sector short_name -> industry names) is the
best-effort suggestion used when importing an industry to propose its sector;
it is NOT seeded into any table.
"""

# (short_name/slug, display name, [member industry names])
_SECTOR_MAP: list[tuple[str, str, list[str]]] = [
    ("agriculture", "Agriculture", ["Agriculture"]),
    ("real_estate_and_professional_services", "Real Estate & Professional Services",
     ["Real Estate", "Staffing HR"]),
    ("financial_services", "Financial Services",
     ["Banking", "Payments Fintech", "Health Insurance", "Life Insurance"]),
    ("healthcare_and_life_sciences", "Healthcare & Life Sciences",
     ["Healthcare", "Pharmaceuticals", "Genomics Biotech", "Clinical Trials"]),
    ("energy_and_utilities", "Energy & Utilities",
     ["Oil Gas", "Energy Utilities", "Mining", "Water Utilities"]),
    ("travel_transport_logistics", "Travel, Transport & Logistics",
     ["Airlines", "Travel Hospitality", "Transport Shipping", "Shipping Ports"]),
    ("public_sector_education_nonprofit", "Public Sector, Education & Non-Profit",
     ["Education", "NGO", "Legal", "Waste Management"]),
    ("communications_media_entertainment", "Communications, Media & Entertainment",
     ["Telecommunication", "Media Broadcasting", "Sports Entertainment", "Gaming", "Advertising"]),
    ("manufacturing", "Manufacturing",
     ["Manufacturing", "Chemical Mfg", "Semiconductors", "Automotive", "Construction"]),
    ("retail_and_consumer_goods", "Retail & Consumer Goods",
     ["Retail", "Grocery", "Ecommerce", "Consumer Goods", "Apparel Fashion",
      "Food Beverage", "Restaurants"]),
]

SECTOR_CATALOG: list[dict[str, str]] = [
    {"short_name": slug, "name": label, "description": ""}
    for slug, label, _names in _SECTOR_MAP
]

SECTOR_INDUSTRY_MAP: dict[str, list[str]] = {
    slug: list(names) for slug, _label, names in _SECTOR_MAP
}
