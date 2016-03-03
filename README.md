#ActiveRecord Lite

An Object Relational Mapping (ORM) inspired by ActiveRecord.

## Current features:
+ SQL object - ::table_name, ::all, ::find, ::columns, #attributes, #insert, #update, #save
+ Searchable - SQL 'WHERE' queries
+ Associations - belongs_to, has_many, has_one_through

## How to use:
### General (using pry/irb):
+ clone repository and start ruby interpreter
+ require_relative './ActiveRecord-Lite/lib/associatable.rb'
+ call DBConnection.open(YOUR_DB_FILE_PATH)
+ Create classes that inherit from SQLObject. Use SQLObject methods, searchable, and associatable methods.

### Detailed Example (using pry/irb):
+ Assume current directory is ActiveRecord-Lite
+ SetUp database:  `cat 'volcanoes.sql' | sqlite3 'volcanoes.db'`
+ Start ruby interpreter
+ call `require_relative './lib/associatable.rb'`
+ call `DBConnection.open("./volcanoes.db")`
+ declare classes:
    ```ruby
    class Volcano < SQLObject
      self.table_name = "volcanoes"
      belongs_to :country, foreign_key: :country_id
      has_one_through :continent, :country, :continent
      self.finalize!
    end

    class Country < SQLObject
      has_many :volcanoes, foreign_key: :country_id
      belongs_to :continent

      self.finalize!
    end

    class Continent < SQLObject
      has_many :countries, foreign_key: :continent_id
      self.finalize!
    end
    ```

    #### Method Usage:
    ##### **Searchable:**
    ```ruby
    etna = Volcano.find(1) #=> returns an object representing "Mount Etna"
    Continent.where(name: 'Asia') #=> returns an array with object representing Asia
    ```
    ##### **Attributes:**
    ```ruby
    etna.last_eruption #=> returns "December 3, 2015"
    ```
    ##### **Associations:**
    ```ruby
    italy = etna.country #=> returns an object representing "Italy"
    europe = etna.continent #=> returns an object representing "Europe"

    italy.continent #=> returns an object representing "Europe"
    italy.volcanoes #=> returns array for objects representing "Mount Etna", "Vesuvius", and "Stromboli"

    europe.countries #=> returns an array with objects representing "Italy" and "Iceland"
    ```

### Example (using file):
+ Setup database: `cat 'volcanoes.sql' | sqlite3 'volcanoes.db'`
+ From terminal, call `ruby volcano_example.rb`
