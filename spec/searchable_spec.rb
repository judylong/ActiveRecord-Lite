require 'searchable'

describe 'Searchable' do
  before(:each) { DBConnection.reset }
  after(:each) { DBConnection.reset }

  before(:all) do
    class Volcano < SQLObject
      self.table_name = "volcanoes"
      finalize!
    end

    class Country < SQLObject
      self.table_name = 'countries'

      finalize!
    end
  end

  it '#where searches with single criterion' do
    volcanoes = Volcano.where(name: 'Mount Etna')
    volcano = volcanoes.first

    expect(volcanoes.length).to eq(1)
    expect(volcano.name).to eq('Mount Etna')
  end

  it '#where can return multiple objects' do
    countries = Country.where(continent_id: 3)
    expect(countries.length).to eq(2)
  end

  it '#where searches with multiple criteria' do
    countries = Country.where(name: 'Italy', continent_id: 1)
    expect(countries.length).to eq(1)

    country = countries[0]
    expect(country.name).to eq('Italy')
    expect(country.continent_id).to eq(1)
  end

  it '#where returns [] if nothing matches the criteria' do
    expect(Country.where(name: 'Nowhere')).to eq([])
  end
end
