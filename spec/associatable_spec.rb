require 'associatable'

describe 'Associatable' do
  before(:each) { DBConnection.reset }
  after(:each) { DBConnection.reset }

  before(:all) do
    class Volcano < SQLObject
      self.table_name = 'volcanoes'
      belongs_to :country, foreign_key: :country_id

      finalize!
    end

    class Country < SQLObject
      has_many :volcanoes, foreign_key: :country_id
      belongs_to :continent

      finalize!
    end

    class Continent < SQLObject
      has_many :countries

      finalize!
    end
  end

  describe '::assoc_options' do
    it 'defaults to empty hash' do
      class TempClass < SQLObject
      end

      expect(TempClass.assoc_options).to eq({})
    end

    it 'stores `belongs_to` options' do
      volcano_assoc_options = Volcano.assoc_options
      country_options = volcano_assoc_options[:country]

      expect(country_options).to be_instance_of(BelongsToOptions)
      expect(country_options.foreign_key).to eq(:country_id)
      expect(country_options.class_name).to eq('Country')
      expect(country_options.primary_key).to eq(:id)
    end

    it 'stores options separately for each class' do
      expect(Volcano.assoc_options).to have_key(:country)
      expect(Country.assoc_options).to_not have_key(:country)

      expect(Country.assoc_options).to have_key(:continent)
      expect(Volcano.assoc_options).to_not have_key(:continent)
    end
  end

  describe '#has_one_through' do
    before(:all) do
      class Volcano
        has_one_through :continent, :country, :continent

        self.finalize!
      end
    end

    let(:volcano) { Volcano.find(1) }

    it 'adds getter method' do
      expect(volcano).to respond_to(:continent)
    end

    it 'fetches associated `continent` for a `Volcano`' do
      continent = volcano.continent

      expect(continent).to be_instance_of(Continent)
      expect(continent.name).to eq('Europe')
    end
  end
end
