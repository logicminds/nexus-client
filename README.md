# NexusClient

TODO: Write a gem description

## Installation

Add this line to your application's Gemfile:

    gem 'nexus_client'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install nexus_client

## Usage

client = Nexus::Client.new
client.download_gav('/tmp/ant-4.0.pom', 'org.glassfish.main.external:ant:4.0:central::pom')

or

Nexus::Client.download_gav('/tmp/ant-4.0.pom', 'org.glassfish.main.external:ant:4.0:central::pom')


## CLI Usage

nexus-client --help
nexus-client -e -c /tmp/cache -g 'org.glassfish.main.external:ant:4.0:central::pom' -d /tmp

## TODO

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request


## Examples



