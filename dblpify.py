"""Helper script to automatically standardize a BibTeX database.
"""
import os
import sys
import urllib
import bibtexparser
import dblp

def main(bib_file):
    """Standardize the file given by @bib_file relative to working directory.
    """
    bib_file = os.environ["BUILD_WORKING_DIRECTORY"] + "/" + bib_file
    with open(bib_file, "r") as bibtex_file:
        bib_database = bibtexparser.load(bibtex_file)

    # [name].bib -> [name].dblp.bib
    out_file = open(bib_file[:-4] + ".dblp.bib", "w")

    for i, entry in enumerate(bib_database.entries):
        print("Entry:", i + 1, "/", len(bib_database.entries))
        print("Title:", entry.get("title", "[None]"))
        print("Author:", entry.get("author", "[None]"))
        bibtex_id = entry["ID"]
        results = search_dblp(entry["title"])

        if not results.empty:
            result = select_row(results)

        if results.empty or result is None:
            out_file.write("\n% COULD NOT FIND " + entry["ID"]
                           + ": " + entry.get("title", "[None]")
                           + " by " + entry.get("author", "[None]") + "} \n")
            continue

        bibtex_url = f"https://dblp.uni-trier.de/rec/{result.Id}.bib?param=1"
        bibtex_entry = urllib.request.urlopen(bibtex_url).read().decode("utf-8")
        bibtex_entry = set_id(bibtex_entry, bibtex_id)
        print(bibtex_entry)
        out_file.write(bibtex_entry)
    out_file.close()

def search_dblp(title):
    """Given a paper title, attempt to search for it on DBLP.

    If @title does not match anything, we iteratively loosen our search
    constraints by dropping the last word of the title until results are found.
    """
    title = title.replace("{", "").replace("}", "")
    results = dblp.search([title])
    if results.empty:
        return search_dblp(" ".join(title.split(" ")[:-1]))
    return results

def set_id(bibtex_entry, ID):
    """Given a (string) BibTeX entry, replace its identifier with @ID.
    """
    first_bracket = bibtex_entry.index("{") + 1
    first_comma = bibtex_entry.index(",")
    return bibtex_entry[:first_bracket] + ID + bibtex_entry[first_comma:]

def select_row(results):
    """Given a DataFrame of DBLP entries, prompt the user to select one.

    If the user enters -1, this function will return None.
    """
    print(results[["Type", "Title", "Authors", "Where"]])
    try:
        row = int(input("Select a row (or -1 for none): "))
        if 0 <= row < len(results):
            result = results.iloc[row]
            return result
        if row == -1:
            return None
    except ValueError:
        pass
    return select_row(results)

if __name__ == "__main__":
    main(sys.argv[1])
