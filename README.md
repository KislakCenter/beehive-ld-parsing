# Beehive Script

Scripts to extract and parse [SimpleAnnotationServer][SAS] annotations from 
Daniel Pastorius' [Bee Hive](beehive).

[SAS]: https://github.com/glenrobson/SimpleAnnotationServer "SimpleAnnotationServer on Github"
[beehive]: http://dla.library.upenn.edu/dla/medren/pageturn.html?id=MEDREN_9924875473503681 "Bee Hive on Penn in Hand"


# Usage

Acquire a copy of the Bee Hive annotations in N-quads format.

Install the script and set up Fuseki with the annotations data as described
below. Run the script:

```bash
$ ruby bin/parse_annotations.rb path/to/beehive-data.nq
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
$ mdkir jena
$ tdbloader --loc=jena data/beehive-data-2019-04-12.nq $
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
