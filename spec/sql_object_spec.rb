require 'sql_object'
require 'securerandom'

describe SQLObject do
  before(:each) { DBConnection.reset }
  after(:each) { DBConnection.reset }

  before(:each) do
    class Volcano < SQLObject
      self.table_name = "volcanoes"
      self.finalize!
    end

    class Country < SQLObject
      self.finalize!
    end
  end

  describe '::set_table/::table_name' do
    it '::set_table_name sets table name' do
      expect(Country.table_name).to eq('countries')
    end

    it '::table_name generates default name' do
      expect(Volcano.table_name).to eq('volcanoes')
    end
  end

  describe '::columns' do
    it '::columns gets the columns from the table and symbolizes them' do
      expect(Volcano.columns).to eq([:id, :name, :last_eruption, :country_id])
    end

    it '::columns creates getter methods for each column' do
      v = Volcano.new
      expect(v.respond_to? :something).to be false
      expect(v.respond_to? :name).to be true
      expect(v.respond_to? :id).to be true
      expect(v.respond_to? :country_id).to be true
      expect(v.respond_to? :last_eruption).to be true
    end

    it '::columns creates setter methods for each column' do
      v = Volcano.new
      v.name = "Sakurajima"
      v.id = 33
      v.country_id = 2
      v.last_eruption = "2013"
      expect(v.name).to eq "Sakurajima"
      expect(v.id).to eq 33
      expect(v.country_id).to eq 2
      expect(v.last_eruption).to eq "2013"
    end

    it '::columns created setter methods use attributes hash to store data' do
      v = Volcano.new
      v.name = "Sakurajima"
      v.last_eruption = "2013"
      expect(v.instance_variables).to eq [:@attributes]
      expect(v.attributes[:name]).to eq "Sakurajima"
      expect(v.attributes[:last_eruption]).to eq "2013"
    end
  end

  describe '#initialize' do
    it '#initialize properly sets values' do
      v = Volcano.new(name: 'Irazu', id: 100, country_id: 99, last_eruption: "December 1994")
      expect(v.name).to eq 'Irazu'
      expect(v.id).to eq 100
      expect(v.country_id).to eq 99
      expect(v.last_eruption).to eq "December 1994"
    end

    it '#initialize throws the error with unknown attr' do
      expect do
        Volcano.new(favorite_color: 'Green')
      end.to raise_error "unknown attribute 'favorite_color'"
    end
  end

  describe '::parse_all' do
    it '::parse_all turns an array of hashes into objects' do
      hashes = [
        { name: 'volcano1', country_id: 1, last_eruption: "Ongoing" },
        { name: 'volcano2', country_id: 2, last_eruption: "Unknown" }
      ]

      volcanoes = Volcano.parse_all(hashes)
      expect(volcanoes.length).to eq(2)
      hashes.each_index do |i|
        expect(volcanoes[i].name).to eq(hashes[i][:name])
        expect(volcanoes[i].country_id).to eq(hashes[i][:country_id])
        expect(volcanoes[i].last_eruption).to eq(hashes[i][:last_eruption])
      end
    end
  end

  describe '::all/::find' do
    it '::all returns all the volcanoes' do
      volcanoes = Volcano.all

      expect(volcanoes.count).to eq(7)
      volcanoes.all? { |volcano| expect(volcano).to be_instance_of(Volcano) }
    end

    it '::find finds objects by id' do
      v = Volcano.find(1)

      expect(v).not_to be_nil
      expect(v.name).to eq('Mount Etna')
      expect(v.last_eruption).to eq('December 3, 2015')
    end

    it '::find returns nil if no object has the given id' do
      expect(Volcano.find(123)).to be_nil
    end
  end

  describe '#insert' do
    let(:volcano) { Volcano.new(name: 'Popocatepetl', country_id: 4, last_eruption: "Ongoing") }

    before(:each) { volcano.insert }

    it '#attribute_values returns array of values' do
      volcano = Volcano.new(id: 123, name: 'vol1', country_id: 1, last_eruption: "Unknown")

      expect(volcano.attribute_values).to eq([123, 'vol1', "Unknown", 1])
    end

    it '#insert inserts a new record' do
      expect(Volcano.all.count).to eq(8)
    end

    it '#insert sets the id' do
      expect(volcano.id).to_not be_nil
    end

    it '#insert creates record with proper values' do
      # pull the volcano again
      vol2 = Volcano.find(volcano.id)

      expect(vol2.name).to eq('Popocatepetl')
      expect(vol2.country_id).to eq(4)
    end
  end

  describe '#update' do
    it '#update changes attributes' do
      country = Country.find(2)

      country.name = 'Russia'
      country.update

      # pull the country again
      country = Country.find(2)
      expect(country.name).to eq('Russia')
    end
  end

  describe '#save' do
    it '#save calls save/update as appropriate' do
      country = Country.new
      expect(country).to receive(:insert)
      country.save

      country = Country.find(1)
      expect(country).to receive(:update)
      country.save
    end
  end
end
