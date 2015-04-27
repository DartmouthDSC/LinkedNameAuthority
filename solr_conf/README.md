# Configuration for Solr 5.0.0
The Solr configuration in this directory was updated to match the syntax and
organization required by Solr 5.0.0. The configuration itself was not changed.
In this configuration we are continuing to use standalone mode and not solrcloud.

###Installing
This directory should be copied into the SOLR_HOME directory, by default
the directory is set to `/var/solr/data`.

###Cores
Cores are defined by directories under SOLR_HOME with core.properties file.
Two cores currently define development and test. Development is the default
core. They both use the same configuration set defined in
`configsets/default-hydra`.

###Changes made to solr.xml
- Default core is now defined by the `loadOnStartup` property in the
core.properties file of the default core.
- adminPath and persistent are no longer supported.
- New tag with plugin library directory.
- Core now defined as explained above.

###configsets
Made the default solr configuration in hydra its own configset(default-hydra),
both the development and testing core will use this configuration.

###Helpful Apache Solr Wiki Pages:

Example of Solr Home 
https://cwiki.apache.org/confluence/display/solr/A+Step+Closer

Moving to New solr.xml Format
https://cwiki.apache.org/confluence/display/solr/Moving+to+the+New+solr.xml+Format

solr.xml format
https://cwiki.apache.org/confluence/display/solr/Format+of+solr.xml
