# InterSystems iKnow COVID-19 Explorer

A large set of research articles on COVID-19 and similar viruses [has been made available to the general public](https://pages.semanticscholar.org/coronavirus-research) for research and experimentation. At InterSystems, we are looking into ways to leverage our NLP technology (for which a standalone version is [available as open source](https://github.com/intersystems/iknow)) to make this dataset easer to browse and help people draw insights from it more quickly. 

This repository contains everything you need to get started.

## Setting up with Docker

1. Clone the repository, navigate into its root directory and build the image:

    ```
    docker build --tag covid-19 .
    ```

    This will set up and load the full demo environment. For container size convenience, the script only downloads the noncomm_use_subset archive from the [SemanticScholar portal](https://pages.semanticscholar.org/coronavirus-research). If you'd like to process other / additional archives, you can easily update or extend the `Dockerfile` (`iris.script` will transparently pick up any archive).

    Note that processing all archives together will require a database beyond the maximum size allowed by the Community Edition license terms. You can update the `Dockerfile` to start from a full IRIS image and put your iris.key file in the repository root, where the build script will pick it up.

2. Start your container:

    ```
    docker run -d --name covid-19 -p 9091:51773 -p 9092:52773 covid-19
    ```

3. Access the index page at: http://localhost:9092/csp/user/menu.csp. 
    When prompted for a password, use the default _SYSTEM/SYS combo
	
  ![Screenshot](https://github.com/bdeboe/isc-iknow-covid/blob/master/docs/img/screenshot-menu.jpg)


## Setting up on an existing IRIS instance

1. Import the contents of this repository into your namespace of choice (feel free to take a blank one) and compile, e.g. using:

    ```
    do $system.OBJ.LoadDir("path_to_repo/src/iris/",,"ck",1)
    ```
    Besides loading a variety of classes and demo apps (including the [Set Analysis tool](https://github.com/bdeboe/isc-iknow-setanalysis) and [iFind Search Portal](https://github.com/bdeboe/isc-iknow-ifindportal)), this will also set up a web application to configure a REST handler. 
	
2. Load any or all of the 4 `.tar.gz` files from the [SemanticScholar portal](https://pages.semanticscholar.org/coronavirus-research), unzipping and untarring them until you have the per-article .json files in a folder structure resembling the following (as per your choice of downloads):

    ```
    some_path/
    some_path/comm_use_subset/
    some_path/comm_use_subset/000b7d1517ceebb34e1e3e817695b6de03e2fa78.json
    ...
    some_path/pmc_custom_license/
    some_path/pmc_custom_license/0a3a221e70ed8497ac197567fe69e7d384759826.json
    ...
    ```

2. Now use the `COVID.Utils` class to load the data into the `Research.FullDocument` table by pointing it at the path you unzipped your data files to:

    ```
    do ##class(COVID.Utils).LoadAll("some_path")
    ```
    As this builds an iFind search index for all loaded records, this method may take a while. You can also load an individual folder at a time:

    ```
    do ##class(COVID.Utils).LoadDir("some_path/pmc_custom_license/")
    ```
  
3. Now build the iKnow domains (which will take time if you loaded all 4 datasets!):

    ```
    w ##class(COVID.Domains.Abstracts).%Build()
    w ##class(COVID.Domains.BodyText).%Build()
    ```

4. Locate the index page, updating this URL with the right web port and namespace you're using: http://localhost:52773/csp/covid/menu.csp
	
  ![Screenshot](https://github.com/bdeboe/isc-iknow-covid/blob/master/docs/img/screenshot-menu.jpg)
  
  
## Notes

We've noticed that some JSON files have issues (or cause them) when indexed. For example, some articles have a full paragraph in their title field, which is of course inconvenient. The script will address many of these issues transparently and skip files we just can't deal with. Given that this is only a tiny fraction of the full dataset, that shouldn't be much of an issue!

More on the iKnow Natural Language Processing technology can be found [here](https://github.com/intersystems/iknow/wiki)

If you run into trouble, please file an [issue](https://github.com/bdeboe/isc-iknow-covid/issues).