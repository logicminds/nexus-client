require "spec_helper"

describe 'Integration Nexus::Client' do

  file = '/tmp/ant-4.0.pom'
  shafile = '/tmp/ant-4.0.pom.sha1'

  after(:all) do
    FileUtils.rm(file) if File.exists?(file)
    FileUtils.rm(shafile) if File.exists?(shafile)

    FileUtils.rm_rf('/tmp/cache')  if File.exists?('/tmp/cache')
  end

  subject(:client) { Nexus::Client.new('https://repository.jboss.org/nexus','/tmp/cache') }

  let(:gav) do
    Nexus::Gav.new('org.glassfish.main.external:ant:4.0:central::pom')
  end


  it 'can read sha1 gav data' do
    expect(client.gav_data(gav)['sha1']).to eq('387951c0aa333024b25085d76a8ad77441b9e55f')
  end
  it 'can download using Class method' do
    expect(Nexus::Client.download('/tmp',gav.to_s,'/tmp/cache', true, true,'https://repository.jboss.org/nexus') == true)
    expect(File.exists?(file) == true )
  end

  it 'cache on' do
    expect(Nexus::Client.download('/tmp',gav.to_s,'/tmp/cache', true, true,'https://repository.jboss.org/nexus') == true )
    expect(File.exists?(file)).to be_true
    expect(File.exists?('/tmp/cache/org/glassfish/main/external/ant/387951c0aa333024b25085d76a8ad77441b9e55f.cache')).to be_true

  end

  # it 'cache analytics file is created' do
  #   FileUtils.rm(file)
  #   FileUtils.rm_rf('/tmp/cache')
  #   expect(client.download_gav('/tmp',gav.to_s) == true )
  #   expect(File.exists?('/tmp/cache/cache_analytics.json') == true )
  #   cache = client.cache
  #  # expect(cache.analytics['896f6a67964939a62f6b29e3d6fa13139ee92f9a']['time_saved']).to eq(0)
  #  # expect(cache.analytics['896f6a67964939a62f6b29e3d6fa13139ee92f9a']['bandwidth_saved']).to eq('0 B')
  # end

  # it 'cache analytics file is populated correctly' do
  #   FileUtils.rm(file)
  #   FileUtils.rm_rf('/tmp/cache')
  #   n_client = Nexus::Client.new(nil,'/tmp/cache')
  #   n_client.download_gav('/tmp',gav.to_s)
  #   bytes = n_client.cache.analytics['896f6a67964939a62f6b29e3d6fa13139ee92f9a']['size']
  #   bytes = Filesize.from(bytes).to_i
  #   time =  n_client.cache.analytics['896f6a67964939a62f6b29e3d6fa13139ee92f9a']['total_time_secs']
  #   (0..10).each do | num |
  #     n_client.download_gav('/tmp',gav.to_s)
  #     cache = n_client.cache.analytics['896f6a67964939a62f6b29e3d6fa13139ee92f9a']
  #     expect(cache['hit_count']).to eq(num)
  #     #expect(cache['time_saved']).to eq(time * num)   # errors out due to rounding error
  #     #expect(Filesize.from(cache['bandwidth_saved']).to_i).to eq((num * bytes ))
  #     FileUtils.rm(file)
  #   end
  #
  # end

  it 'cache off' do
    FileUtils.rm(file)  if File.exists?(file)
    FileUtils.rm_rf('/tmp/cache/com')
    expect(Nexus::Client.download('/tmp',gav.to_s,'/tmp/cache', false,false,'https://repository.jboss.org/nexus') == true)
    expect(File.exists?(file) == true )
    expect(File.exists?('/tmp/cache/org/glassfish/main/external/ant/*.cache') == false )

  end

end

