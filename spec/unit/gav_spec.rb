require "spec_helper"

describe Nexus::Gav do
  gav_str = 'org.glassfish.main.external:ant:4.0:central::pom'
  let(:gav) do
    Nexus::Gav.new(gav_str)
  end

  it 'creates gav resource' do
    expect(gav.group).to eq('org.glassfish.main.external')
    expect(gav.artifact).to eq('ant')
    expect(gav.version).to eq('4.0')
    expect(gav.repo).to eq('central')
    expect(gav.classifier).to eq('')
    expect(gav.extension).to eq('pom')
  end
  it 'raises an error' do
    expect { Nexus::Gav.new(nil) }.to raise_error(RuntimeError, 'Must provide gav_str in the form of "<group>:<artifact>:<version>:<repo>:<classifier>:<extension>"')
  end

  it 'should create filename' do
    expect(gav.filename).to eq("ant-4.0.pom")
  end

  context "#to_s" do
    it 'should convert to string' do
      expect(gav.to_s).to eq(gav_str)
    end
  end

  context '#filename' do
    let(:gav) do
      Nexus::Gav.new('org.glassfish.main.external:ant:4.0:central:blah:pom')
    end
    it 'should create filename with classifier' do
      expect(gav.filename).to eq("ant-4.0-blah.pom")
    end
  end


  context '#to_hash' do
    it 'should convert to string' do
      expect(gav.to_hash).to eq({:g=>"org.glassfish.main.external", :a=>"ant",
                                 :v=>"4.0", :r=>"central", :c=>"", :e=>"pom"})
    end
  end

  context "#dir_location" do
    it 'should return dir_location' do
       expect(gav.dir_location).to eq("org/glassfish/main/external/ant")
    end
  end


end
