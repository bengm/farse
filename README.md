# FARse

**Problem:** The Federal Acquisition Regulation (FAR) is used all over the place, but is only published as HTML/PDF. See [acquisition.gov](https://www.acquisition.gov/?q=browsefar).

**Solution:** Build a parser to transform the FAR content into structured data, currently json.

## Input

The input data was obtain via this method:

 - Go to FAR web site at https://www.acquisition.gov/?q=browsefar
 - Near top of page: "Download Entire FAR" (HTML) https://www.acquisition.gov/sites/default/files/current/far/zip/html/FAC%202005-92%20HTML%20Files.zip
 - Unzip above into /html directory

## Output

### Format

The json has a relatively flat format. Each clause has a number, title and an array of children. Each child has text, a type, and possibly a level (i.e. outline indentation level). The level is not reliable as the source data is bad in this regard (see issues below). A partial example is below

```json

  {
    "number": "52.249-14",
    "title": "Excusable Delays.",
    "children": [
      {
        "text": "As prescribed in 49.505(b), insert the following clause in solicitations and contracts for supplies, services, construction, and research and development on a fee basis whenever a cost-reimbursement contract is contemplated. Also insert the clause in time-and-material contracts, and labor-hour contracts. When used in construction contracts, substitute the words “completion time” for “delivery schedule” in the last sentence of the clause.",
        "type": "paragraph",
        "level": null
      },
      {
        "text": "Excusable Delays (Apr 1984)",
        "type": "paragraph",
        "level": null
      },
      {
        "text": "(a) Except for defaults of subcontractors at any tier, the Contractor shall not be in default because of any failure to perform this contract under its terms if the failure arises from causes beyond the control and without the fault or negligence of the Contractor. Examples of these causes are (1) acts of God or of the public enemy, (2) acts of the Government in either its sovereign or contractual capacity, (3) fires, (4) floods, (5) epidemics, (6) quarantine restrictions, (7) strikes, (8) freight embargoes, and (9) unusually severe weather. In each instance, the failure to perform must be beyond the control and without the fault or negligence of the Contractor. “Default” includes failure to make progress in the work so as to endanger performance.",
        "type": "paragraph",
        "level": null
      }
    ]
  }

```

### Files

The output_data folder contains a bunch of json files. There is one for each clause... plus the complete_far.json file with everything.

## Status and Issues

The tool works... but there are a few edge cases documented in the code for handling some odd/rare bits of content. This will miss content from a few sources.

The source data is not perfect. The outline structure is not properly represented. Additional text parsing could tease this out, i.e. recognizing "(a)" and "iii" to determine the outline level and build up a more robust parent/child relationship.
