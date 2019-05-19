#! /usr/bin/python3

from time import gmtime, strftime


def get_current_date():
    return strftime("%y-%m-%d", gmtime())


def construct_basic_description():
    description = """
# BioSAK
## _Biological Swiss Army Knife created with Docker!_

## _Version_: {}

## _Description_:

This repository contains Docker environment for execution of biological
pipelines, data exploration and mining and many more. It is based on Jupyter
repository
 [Dockerhub:jupyter/datascience-notebook](https://hub.docker.com/r/jupyter/datascience-notebook/)
with additional packages like bwa, samtools and more. Packages are installed with conda.
Additionally [HKL](https://github.com/grzadr/hkl) library is installed
""".format(get_current_date())

    return description


def parse_packages(supplier, file_name):
    output = "## _{} Packages_:\n".format(supplier)

    for line in open(file_name, "r"):
        line = line.rstrip()

        if line.startswith("# "):
            output += "#### _{}_:\n".format(line.lstrip("# "))
            output += "|      Name      |     Version     |\n"
            output += "|:---------------|:----------------|\n"
        elif not len(line):
            output += "\n"
        else:
            output += "|{}|{}|\n".format(*line.rstrip().replace("==", "=").split("="))

    return output


def main():
    readme = open("README.md", "w")

    print(construct_basic_description(), file=readme)
    print(file=readme)

    for supplier, file_name in (("Conda", "packages/packages_conda.list"),
                                ("Pip", "packages/packages_pip.list")):
        print(parse_packages(supplier, file_name), file=readme)


if __name__ == "__main__":
    main()
