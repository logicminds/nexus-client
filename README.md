# NexusClient
The nexus client is a ruby wrapper around the nexus REST API for downloading maven artifacts.
It features the ability to cache artifacts and also performs artifact checksums to ensure you only
download the artifact once.  This gem was originally designed for use with configuration management software like puppet.

This gem does not require maven or any of the maven settings files.  It was originally created to use with 
configuration management software to download artifacts to hundreds of servers.  A CLI tool was created for this purpose
to ease downloading of artifacts on any system.

## Installation

Add this line to your application's Gemfile:

    gem 'nexus_client'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install nexus_client

## Features
### Cache repository  
The cache repository feature if enabled can be used to cache artifacts much like maven.  However since this
gem does not use maven you are free to store the artifacts where ever you want. This works great for downloading the same
artifact on the same system.  However, the cache feature was built to be used across a shared file system like NFS
so if multiple systems are downloading the same artifact you can reduce the time and bandwidth needed to download large
artifacts.  This feature alone is like having a mini nexus proxy on your network!

### Automatic artifact checksums 
This gem will grab the sha1 checksum from the nexus server and compare the checksum 
with the downloaded artifact.  If the checksums are different and error will be raised.  If the checksums match, a file
will be created with a extension of sha1 after the artifact is downloaded.  This sha1 file additionally contains the sha1 checksum of the file.
This sha1 file is created as a trigger mechanism for configuration management software and also to speed up sha1 computation time of the artifact.
```shell
Coreys-MacBook-Pro-2:tmp$ nexus-client --nexus-host https://repository.jboss.org/nexus -e -c /tmp/cache -g 'org.glassfish.main.external:ant:4.0:central::pom' -d /tmp
Coreys-MacBook-Pro-2:tmp$ ls -l
   -rw-r--r--  1 user1      wheel    8853 Oct 22 14:26 ant-4.0.pom
   -rw-r--r--  1 user1      wheel      40 Oct 22 14:26 ant-4.0.pom.sha1
   
Coreys-MacBook-Pro-2:tmp$ more ant-4.0.pom.sha1
   387951c0aa333024b25085d76a8ad77441b9e55f
```

### Smart Artifact Retrieval 
This gem will use artifact checksums to ensure the artifact is only downloaded once.  This
is really important during configuration management runtime when the artifact downloading process is expected run multiple times.
This is even more important when you use artifact snapshots.  Artifacts that are snapshots can contain different checksums
at any time so its important that we download only when a new snapshot is detected by comparing the checksums.

### Cache Analytics(Experimental) 
This feature records the cache usage and shows just how much bandwidth has been saved and what
artifacts are currently cached.  This feature is experimental and is not feature complete.  It was originally designed
to show historically analysis of artifacts and make this information available to shell scripts, graphite and other reporting mechanisms.
This could be used later to send alerts when artifact sizes between versions/snapshots are significantly different from each other.


## Ruby Usage

```ruby
client = Nexus::Client.new
client.download_gav('/tmp/ant-4.0.pom', 'org.glassfish.main.external:ant:4.0:central::pom')
```
or

```ruby
Nexus::Client.download_gav('/tmp/ant-4.0.pom', 'org.glassfish.main.external:ant:4.0:central::pom')
```

## CLI Usage
We have also created a simple CLI tool that makes it easy to download artifacts from any nexus server.

```shell
nexus-client --help
Options:
   --destination, -d <s>:   destination directory to download file to
    --gav-string, -g <s>:   The nexus GAV value: group:artifact:version:repository:classifier:extension
     --cache-dir, -c <s>:   The directory to cache files to
      --enable-cache, -e:   Enable cache
    --nexus-host, -n <s>:   Nexus host url, if left blank reads from ~/.nexus_host
  --enable-analytics, -a:   Enable cache analytics, requires sqlite3 gem (experimental!)
              --help, -h:   Show this message
              
nexus-client --nexus-host https://repository.jboss.org/nexus -e -c /tmp/cache -g 'org.glassfish.main.external:ant:4.0:central::pom' -d /tmp
```

## Tips

Create a nexus host file to store the nexus host url.  This can same time if your nexus host url is the same.  By default
the nexus-client CLI will override the stored url in your nexus_host file when passing in the --nexus-host argument.

```shell
   Coreys-MacBook-Pro-2:~$ pwd
   /Users/user1
   Coreys-MacBook-Pro-2: echo 'https://repository.jboss.org/nexus' > ~/.nexus_host
   Coreys-MacBook-Pro-2:~$ more .nexus_host
   https://repository.jboss.org/nexus
```
## TODO
* Extend usage to other supported maven server solutions (artifactory, archiva)
* Implement a feature toggle to enable parallel downloads.
* Finish analytics feature
* Remove usage of typheous and other C compiled dependent gems  (conflicts with parallel feature)
* Add feature to upload artifacts to nexus server
* Add basic user authentication


## OS Support
Should work on all *nix platforms.  Windows may also be supported but it has never been tested.
If you use this gem on windows please let me know so I can update this doc.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request


## Examples



