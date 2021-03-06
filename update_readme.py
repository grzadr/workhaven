#! /usr/bin/python3

from time import gmtime, strftime


def get_current_date():
    return strftime("%Y-%m-%d", gmtime())


def construct_basic_description():
    description = """
# WorkHaven

## _Environment for Data Science created with Docker!_

## _Version_: {}

## _Description_

This repository contains Docker environment for data mining and statistical analyses, data exploration and mining and many more. It is based on Jupyter
repository
 [Dockerhub:jupyter/minimal-notebook](https://hub.docker.com/r/jupyter/minimal-notebook/)
Additional packages are installed with conda and pip.
Additionally [AGizmo](https://github.com/grzadr/agizmo) library is installed.
""".format(get_current_date())

    return description


def parse_packages(supplier, file_name):
    output = "## _{} Packages_\n\n".format(supplier)

    for line in open(file_name, "r"):
        line = line.rstrip()

        if line.startswith("### "):
            output += "### _{}_\n\n".format(line.lstrip("# "))
            output += "|      Name      |     Version     |\n"
            output += "|:---------------|:----------------|\n"
        elif line.startswith("#"):
            continue
        elif not len(line):
            output += "\n"
        elif "=" in line or "==" in line:
            output += "|{}|{}|\n".format(*line.rstrip().replace("==", "=").split("="))
        else:
            output += "|{}|NA|\n".format(line)

    return output


def main():
    readme = open("README.md", "w")

    print(construct_basic_description(), file=readme)

    for supplier, file_name in (("Conda", "packages/conda.list"),
                                ("Pip", "packages/pip.list")):
        print(parse_packages(supplier, file_name), file=readme)


if __name__ == "__main__":
    main()
