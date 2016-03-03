require_relative './lib/associatable.rb'

DBConnection.open("./volcanoes.db")

class Volcano < SQLObject
  self.table_name = "volcano"
  belongs_to :country, foreign_key: :country_id
  has_one_through :continent, :country, :continent
  self.finalize!
end

class Country < SQLObject
  self.table_name = "country"
  has_many :volcanoes, foreign_key: :country_id
  belongs_to :continent

  self.finalize!
end

class Continent < SQLObject
  self.table_name = "continent"
  has_many :countries, foreign_key: :continent_id
  self.finalize!
end

puts "Searchable:"
etna = Volcano.find(1) #=> returns an object representing "Mount Etna"
etna_country = etna.country
asia = Continent.where(name: 'Asia') #=> returns an array with object representing Asia

puts "A volcano object: #{etna.name}"
puts "A country object: #{etna_country.name}"
puts "A continent object: #{asia.first.name}"
puts "========================="

puts "Attributes:"
erupt = etna.last_eruption #=> returns "December 3, 2015"
puts "Etna's last eruption: " + erupt
puts "========================="

puts "Associations:"
italy = etna.country #=> returns an object representing "Italy"
europe = etna.continent #=> returns an object representing "Europe"

icontinent = italy.continent #=> returns an object representing "Europe"
ivolcanoes = italy.volcanoes #=> returns array for objects representing "Mount Etna", "Vesuvius", and "Stromboli"

ecountries = europe.countries

puts "Etna's country: #{italy.name}"
puts "Etna's continent: #{europe.name}"
puts "Italy's continent: #{icontinent.name}"
puts "Italy's volcanoes: #{ivolcanoes.map{|vol| vol.name}}"
puts "Europe's countries: #{ecountries.map{|eco| eco.name}}"
