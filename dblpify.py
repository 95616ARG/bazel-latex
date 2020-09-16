import os
import sys
import urllib
import dblp
import bibtexparser

def main(bib_file):
    bib_file = os.environ["BUILD_WORKING_DIRECTORY"] + "/" + bib_file
    with open(bib_file, "r") as bibtex_file:
        bib_database = bibtexparser.load(bibtex_file)

    # [name].bib -> [name].dblp.bib
    out_file = open(bib_file[:-4] + ".dblp.bib", "w")

    for entry in bib_database.entries:
        print("Paper:", entry["title"])
        bibtex_id = entry["ID"]
        results = search_dblp(entry["title"])
        if not results.empty:
            result = select_row(results)
            if result is None:
                out_file.write(f"\n% COULD NOT FIND {entry['ID']}: {entry['title']} by {entry['author']} \n")
                continue
            bibtex_url = f"https://dblp.uni-trier.de/rec/{result.Id}.bib?param=1"
        else:
            out_file.write(f"\n% COULD NOT FIND {entry['ID']}: {entry['title']} by {entry['author']} \n")
            continue
        bibtex_entry = urllib.request.urlopen(bibtex_url).read().decode("utf-8")
        bibtex_entry = set_id(bibtex_entry, bibtex_id)
        print(bibtex_entry)
        out_file.write(bibtex_entry)
    out_file.close()

def search_dblp(title):
    title = title.replace("{", "").replace("}", "")
    results = dblp.search([title])
    if results.empty:
        return search_dblp(" ".join(title.split(" ")[:-1]))
    return results

def set_id(bibtex_entry, ID):
    first_bracket = bibtex_entry.index("{") + 1
    first_comma = bibtex_entry.index(",")
    return bibtex_entry[:first_bracket] + ID + bibtex_entry[first_comma:]

def select_row(results):
    print(results)
    row = None
    while True:
        try:
            row = int(input("Select a row: "))
            if 0 <= row < len(results):
                break
            if row == -1:
                return None
        except ValueError:
            continue
    result = results.iloc[row]
    return result

if __name__ == "__main__":
    main(sys.argv[1])
