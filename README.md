# Beehive Script



These are scripts to extract and parse annotations of University of Pennsylvania Ms. Codex 726, Daniel Pastorius' "[Bee Hive](beehive)" as a single CSV file. These annotations were generated using Glen Robson's [SimpleAnnotationServer][SAS] between 2016 and 2023.

For more information on this project and to see its results, visit the [Digital Beehive site][digital-beehive]. For the annotation data and IIIF manifests, see the [Beehive data repository][beehive-data] on GitHub.

The CSV output by this script is used to generate the data and pages used to build the Digital Beehive Jekyll/Wax site, which is hosted on GitHub Pages. The [Digital Beehive website code][digital-beehive-code] is also hosted on GitHub. There is a separate repository for the website generation scripts, [beehive-annotation-scripts][beehive-annotation-scripts]


[SAS]: https://github.com/glenrobson/SimpleAnnotationServer "SimpleAnnotationServer on Github"
[beehive]: https://franklin.library.upenn.edu/catalog/FRANKLIN_9924875473503681 "The Bee Hive in the Penn Library catalog"
[digital-beehive]: http://kislakcenter.github.io/digital-beehive/ "The Digital Beehive website"
[beehive-data]: https://github.com/KislakCenter/beehive-data "Beehive data repository on GitHub"
[digital-beehive-code]: https://github.com/KislakCenter/digital-beehive "Digital Beehive Jekyll/Wax code"
[beehive-annotation-scripts]: https://github.com/KislakCenter/beehive-annotation-scripts "Digital Beehive generation scripts"



# Usage

Update `data/beehive-data.nq` with the latest version of Beehive SAS exported
N-quads data.

Install the script and set up Fuseki with the annotations data as described
below. 

CSV is written to standard output:

```bash
$ bundle exec ruby bin/parse_annotations.rb > output.csv
```

```csv
volume,image_number,head,entry,topic,xref,see,index,item,unparsed,line,selection,full_image,annotation_uri
...
Volume 2,21,,Jesting,Jesting,buffoonry|1119 [Jest],,jesting,#item-8fd26eddf,,Entry: Jesting|Topic: Jesting|XRef: buffoonry|XRef: 1119 [Jest]|Index: jesting|#item-8fd26eddf|,"https://stacks.stanford.edu/image/iiif/fm855tg5659%2F1607_0488/360,256,3011,363/full/0/default.jpg",https://stacks.stanford.edu/image/iiif/fm855tg5659%2F1607_0488/full/full/0/default.jpg,http://dev.llgc.org.uk/annotation/1508858832957
Volume 2,21,,Jesuite,Jesuite,1292 [Jesuites],,Jesuite,#item-c421e7050,,Entry: Jesuite|Topic: Jesuite|XRef: 1292 [Jesuites]|Index: Jesuite|#item-c421e7050,"https://stacks.stanford.edu/image/iiif/fm855tg5659%2F1607_0488/350,619,3035,318/full/0/default.jpg",https://stacks.stanford.edu/image/iiif/fm855tg5659%2F1607_0488/full/full/0/default.jpg,http://dev.llgc.org.uk/annotation/1508859070768
Volume 3,25,,,,,,,,"","","https://stacks.stanford.edu/image/iiif/gw497tq8651%2F1607_0968/152,2097,448,148/full/0/default.jpg",https://stacks.stanford.edu/image/iiif/gw497tq8651%2F1607_0968/full/full/0/default.jpg,http://dev.llgc.org.uk/annotation/1508859115466
Volume 3,25,,,,,,,,"","","https://stacks.stanford.edu/image/iiif/gw497tq8651%2F1607_0968/149,2254,480,113/full/0/default.jpg",https://stacks.stanford.edu/image/iiif/gw497tq8651%2F1607_0968/full/full/0/default.jpg,http://dev.llgc.org.uk/annotation/1508859120407
Volume 2,21,,Jesus,Jesus,Christ|Saviour,,Jesus,#item-fc54ff4b7,,Entry: Jesus|Topic: Jesus|XRef: Christ|XRef: Saviour|Index: Jesus|#item-fc54ff4b7,"https://stacks.stanford.edu/image/iiif/fm855tg5659%2F1607_0488/359,929,2974,442/full/0/default.jpg",https://stacks.stanford.edu/image/iiif/fm855tg5659%2F1607_0488/full/full/0/default.jpg,http://dev.llgc.org.uk/annotation/1508859135558
...

```



# Install


## Requirements

- Ruby v2.7.6
- Bundler gem
- [Apache Jena and Jena/Fuseki][apache-jena]

[apache-jena]: https://jena.apache.org/download/ "Apache Jena site"

## Download this repository and install required gems

```
git clone https://github.com/KislakCenter/beehive-ld-parsing.git
cd beehive-ld-parsing
bundle install
```

### Install and configure Apache Jena and Jena/Fuseki

Download and unzip/untar Apache Jena and Jena/Fuseki on your system.

Create a copy of `sample.env` and name it `.env`.

```
cp sample.env .env
```

Edit `.env` to match your Apache Jena and Jena/Fuseki installations


### Import the latest Beehive annotations into Jena

Get the latest Beehive annotations in N-Quads format from the [Beehive Data repository][beehive-data].


Your can use the script `import_annotations.sh`:

```
./import_annotations.sh path/to/beehive-annotations.nq
```

Or do it yourself manually:


```bash
source .env # configure Jena/Fuseik environment
rm -rf jena # remove existing store
# the following creates the `jena` folder
tdbloader --loc=jena path/to/beehive-annotations.nq
```

### Setup Fuseki with the annotation data

The following runs Fuseki as a standalone server. The annotation parsing script talks to the Fuseki SPARQL endpoint to extract the annotations.

For more information on running standalone Fuseki see the [Fuseki page][fuseki-standalone].

[fuseki-standalone]: https://jena.apache.org/documentation/fuseki2/fuseki-run.html#fuseki-standalone-server "Fuseki standalone server instructions"


Run the script `start_fuseki.sh`:

```
./start_fuseki.sh
```

You should see something like the following

```
16:10:17 INFO  Server          :: Apache Jena Fuseki 4.8.0
16:10:17 INFO  Config          :: FUSEKI_HOME=/Users/username/Java/apache-jena-fuseki-4.8.0
16:10:17 INFO  Config          :: FUSEKI_BASE=/Users/username/code/beehive-ld-parsing/run
16:10:17 INFO  Config          :: Shiro file: file:///Users/username/code/beehive-ld-parsing/run/shiro.ini
16:10:18 INFO  Server          :: Path = /beehive
16:10:18 INFO  Server          ::   Memory: 4.0 GiB
16:10:18 INFO  Server          ::   Java:   20.0.1
16:10:18 INFO  Server          ::   OS:     Mac OS X 13.4.1 aarch64
16:10:18 INFO  Server          ::   PID:    34006
16:10:18 INFO  Server          :: Started 2023/06/30 16:10:18 EDT on port 3030
```

If you want to do it manually, you can do this:


```bash
source .env
fuseki-server --config=fuseki_config.ttl
```

# Annotation formats

The script `parse_annotations.rb` parses alphabetical, numerical, and index
entry annotations.

Here are the basic formats:

**Alphabetical entry***

```text
Entry: Apples
Topic: Apples
Xref: Fruit
Index: Apfeln
#item-abcd1234
```

**Numerical entry**

```text
Entry: 1338
Topic: To assault : besiege
Index: assault
Index: besiege
#item-xyz093442393
```

Both alphabetical and numerical entries may contain cross references.

```text
Entry: Abundance
Topic: Abundance
Xref: Too much
Xref: Superfluity
Index: Abundance
#item-xyz093442393
```

**Index entry**

Index entries are distinguished by the presence of the `Head:` field.

```text
Head: absurdity
Entry: a
Entry: 919 [Absurd]
Entry: 2205 [Absurd]
#item-63eec4140
```
