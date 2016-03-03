require 'associatable_options'

describe 'AssocOptions' do
  describe 'BelongsToOptions' do
    it 'provides defaults' do
      options = BelongsToOptions.new('continent')

      expect(options.foreign_key).to eq(:continent_id)
      expect(options.class_name).to eq('Continent')
      expect(options.primary_key).to eq(:id)
    end

    it 'allows overrides' do
      options = BelongsToOptions.new('country',
                                     foreign_key: :country_id,
                                     class_name: 'Country',
                                     primary_key: :country_id
      )

      expect(options.foreign_key).to eq(:country_id)
      expect(options.class_name).to eq('Country')
      expect(options.primary_key).to eq(:country_id)
    end
  end

  describe 'HasManyOptions' do
    it 'provides defaults' do
      options = HasManyOptions.new('volcanoes', 'Country')

      expect(options.foreign_key).to eq(:country_id)
      expect(options.class_name).to eq('Volcano')
      expect(options.primary_key).to eq(:id)
    end

    it 'allows overrides' do
      options = HasManyOptions.new('volcanoes', 'Country',
                                   foreign_key: :country_id,
                                   class_name: 'Vulcan',
                                   primary_key: :country_id
      )

      expect(options.foreign_key).to eq(:country_id)
      expect(options.class_name).to eq('Vulcan')
      expect(options.primary_key).to eq(:country_id)
    end
  end

  describe 'AssocOptions' do
    before(:all) do
      class Volcano < SQLObject
        self.table_name = "volcanoes"
        self.finalize!
      end

      class Country < SQLObject
        self.finalize!
      end
    end

    it '#model_class returns class of associated object' do
      options = BelongsToOptions.new('country')
      expect(options.model_class).to eq(Country)

      options = HasManyOptions.new('volcanoes', 'Country')
      expect(options.model_class).to eq(Volcano)
    end

    it '#table_name returns table name of associated object' do
      options = BelongsToOptions.new('country')
      expect(options.table_name).to eq('countries')

      options = HasManyOptions.new('volcanoes', 'Country')
      expect(options.table_name).to eq('volcanoes')
    end
  end
end

describe 'Associatable' do
  before(:each) { DBConnection.reset }
  after(:each) { DBConnection.reset }

  before(:all) do
    class Volcano < SQLObject
      belongs_to :country, foreign_key: :country_id

      finalize!
    end

    class Country < SQLObject
      self.table_name = 'countries'

      has_many :volcanoes, foreign_key: :country_id
      belongs_to :continent

      finalize!
    end

    class Continent < SQLObject
      has_many :countries

      finalize!
    end
  end

  describe '#belongs_to' do
    let(:etna) { Volcano.find(1) }
    let(:italy) { Country.find(1) }

    it 'fetches `country` from `Volcano` correctly' do
      expect(etna).to respond_to(:country)
      country = etna.country

      expect(country).to be_instance_of(Country)
      expect(country.name).to eq('Italy')
    end

    it 'fetches `continent` from `Country` correctly' do
      expect(italy).to respond_to(:continent)
      continent = italy.continent

      expect(continent).to be_instance_of(Continent)
      expect(continent.name).to eq('Europe')
    end

    it 'returns nil if no associated object' do
      unidentified_volcano = Volcano.find(7)
      expect(unidentified_volcano.country).to eq(nil)
    end
  end

  describe '#has_many' do
    let(:italy) { Country.find(1) }
    let(:italy_continent) { Continent.find(1) }

    it 'fetches `volcanoes` from `Country`' do
      expect(italy).to respond_to(:volcanoes)
      volcanoes = italy.volcanoes

      expect(volcanoes.length).to eq(3)

      expected_volcano_names = ["Mount Etna", "Stromboli", "Vesuvius"]
      3.times do |i|
        volcano = volcanoes[i]

        expect(volcano).to be_instance_of(Volcano)
        expect(volcano.name).to eq(expected_volcano_names[i])
      end
    end

    it 'fetches `countries` from `Continent`' do
      expect(italy_continent).to respond_to(:countries)
      countries = italy_continent.countries

      expect(countries.length).to eq(2)
      expect(countries[0]).to be_instance_of(Country)
      expect(countries[0].name).to eq('Italy')
    end

    it 'returns an empty array if no associated items' do
      volcanoless_country = Country.find(5)
      expect(volcanoless_country.volcanoes).to eq([])
    end
  end
end
