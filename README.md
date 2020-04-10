# InterSystems iKnow CORD-19 Explorer

The CORD-19 corpus (Covid-19 Open Research Dataset) consists of over 30000 research articles on COVID-19 and similar viruses and is [available to the general public](https://pages.semanticscholar.org/coronavirus-research) for research and experimentation. At InterSystems, we are looking into ways to leverage our NLP technology (for which a standalone version is [available as open source](https://github.com/intersystems/iknow)) to make this dataset easer to browse and help people draw insights from it more quickly. 

This repository contains everything you need to get started, automating the process of downloading and processing the dataset and setting up a few demo environments to explore this vast research corpus. We very much value your suggestions on making these interfaces easier to navigate and any particular insights you gleaned through them. Please use the [issues](https://github.com/bdeboe/isc-iknow-covid/issues) section for all these and other kinds of feedback you'd like to share.

The `/docs` folder includes a [PDF explaining how to use the main Domain Explorer interface](https://github.com/bdeboe/isc-iknow-covid/blob/master/docs/COVID-19_Explorer_Documentation.pdf).

## Setting up on an existing IRIS instance

1. Import the contents of this repository into your namespace of choice (feel free to take a blank one) and compile, e.g. using:

    ```
    do $system.OBJ.LoadDir("path_to_repo/src/iris/","ck",,1)
    ```
    Besides loading a variety of classes and demo apps (including the [Set Analysis tool](https://github.com/bdeboe/isc-iknow-setanalysis) and [iFind Search Portal](https://github.com/bdeboe/isc-iknow-ifindportal)), this will also set up a web application to configure a REST handler. 
	
2. Run the following command to download, unzip and import any or all of the 4 `.tar.gz` files from the [SemanticScholar portal](https://pages.semanticscholar.org/coronavirus-research)

    ```
    do ##class(COVID.Utils).Download()
    ```
    This method may take a while and prints a tiny bit of output. You can also load an individual archive (or comma-separated list) at a time:

    ```
    do ##class(COVID.Utils).Download("biorxiv_medrxiv")
    ```
  
3. Now build the iKnow domains (which will take time if you loaded all 4 datasets!):

    ```
    w ##class(COVID.Domains.Abstracts).%Build()
    w ##class(COVID.Domains.BodyText).%Build()
    ```

4. Locate the index page, updating this URL with the right web port and namespace you're using: http://localhost:52773/csp/covid/menu.csp
	
  ![Screenshot](https://github.com/bdeboe/isc-iknow-covid/blob/master/docs/img/screenshot-menu.png)
  
  
## Setting up with Docker

1. Clone the repository, navigate into its root directory and build the image:

    ```
    docker build --tag covid-19 .
    ```

    This will set up and load the demo environment in one go. For image size convenience, the script only downloads the biorxiv_medrxiv archive from the [SemanticScholar portal](https://pages.semanticscholar.org/coronavirus-research). 

    :warning: Note that the image produced by this script becomes quite large, depending on which archive you're processing. This is because the underlying NLP libraries generously generate indices to support a broad variety of queries. You may have to extend your Docker installation's max storage footprint under Settings > Resources > Advanced and/or the [maximum container size](https://docs.docker.com/engine/reference/commandline/dockerd/#options-per-storage-driver). 
    
    A better approach would be to comment out the call to `##class(COVID.Utils).Download()` in `iris.script` and only download / load those files in the *container*, after the image is built. That'd also allow you to map storage outside of the container (see issue #1).

    :warning: Processing all archives together will require a database beyond the maximum size allowed by the Community Edition license terms. You can update the `Dockerfile` to start from a full IRIS image and put your iris.key file in the repository root, where the build script will pick it up.

2. Start your container:

    ```
    docker run -d --name covid-19 -p 9091:51773 -p 9092:52773 covid-19
    ```

3. Access the index page at: http://localhost:9092/csp/user/menu.csp. 
    When prompted for a password, use the default _SYSTEM/SYS combo
	
  ![Screenshot](https://github.com/bdeboe/isc-iknow-covid/blob/master/docs/img/screenshot-menu.png)


## Notes

We've noticed that some JSON files have issues (or cause them) when indexed. For example, some articles have a full paragraph in their title field, which is of course inconvenient. The script will address many of these issues transparently and skip files we just can't deal with. Given that this is only a tiny fraction of the full dataset, that shouldn't be much of an issue!

More on the iKnow Natural Language Processing technology can be found [here](https://github.com/intersystems/iknow/wiki)

If you run into trouble, please file an [issue](https://github.com/bdeboe/isc-iknow-covid/issues).

### Credits

- Thanks to @daimor for sharing an excellent ObjectScript [untar utility](https://github.com/daimor/isc-tar)