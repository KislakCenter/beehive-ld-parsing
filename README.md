# Beehive Script

Scripts to extract and parse [SimpleAnnotationServer][SAS] annotations from 
Daniel Pastorius' [Bee Hive](beehive).

[SAS]: https://github.com/glenrobson/SimpleAnnotationServer "SimpleAnnotationServer on Github"
[beehive]: http://dla.library.upenn.edu/dla/medren/pageturn.html?id=MEDREN_9924875473503681 "Bee Hive on Penn in Hand"


# Usage

Acquire a copy of the Bee Hive annotations in N-quads format.

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

Run bundler:

```bash
$ bundle install
```

### Setup Fuseki with the annotation data

[Get](get-fuseki) and run Fuseki as a [standalone server](fuseki-standalone):

[get-fuseki]: https://jena.apache.org/documentation/fuseki2/#download-fuseki
[fuseki-standalone]: https://jena.apache.org/documentation/fuseki2/fuseki-run.html#fuseki-standalone-server

Set the environment to point to where Fuseki and Jena live on your system.

```bash
export FUSEKI_HOME=$HOME/dev/Java/apache-jena-fuseki-3.11.0
export JENA_HOME=$HOME/dev/Java/apache-jena-3.11.0

PATH=$PATH:$FUSEKI_HOME
PATH=$PATH:$FUSEKI_HOME/bin
PATH=$PATH:$JENA_HOME/bin

export PATH
```

Create directory called `jena`, download a copy of the Bee Hive annotations (you
have to ask Doug Emery for this) and load it into Jena.

NB If you already have a folder called `jena`, delete its contents and reload
the `nq` file data. The script will not work if you load the n-quads data more
than once to the same database.

```bash
$ rm -rf jena
# the following creates the `jena` folder
$ tdbloader --loc=jena data/beehive-data-2019-04-12.nq
``` 

Now start Fuseki using the provided `fuseki_config.ttl`:

```bash
$ fuseki-server --config=fuseki_config.ttl
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
