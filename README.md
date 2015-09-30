#ActiveRecord Lite

An Object Relational Mapping (ORM) inspired by ActiveRecord.

## Current features:
+ SQL object - ::table_name, ::all, ::find, ::columns, #attributes, #insert, #update, #save
+ Searchable - SQL 'WHERE' queries
+ Associations - belongs_to, has_many, has_one_through

## How to use:
+ require_relative './ActiveRecord-Lite/lib/associatable.rb'
+ call DBConnection.open(YOUR_DB_FILE_PATH)
+ Create classes that inherit from SQLObject. Use SQLObject methods, searchable, and associatable methods.
