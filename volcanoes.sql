CREATE TABLE volcanoes (
  id INTEGER PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  last_eruption VARCHAR(255) NOT NULL,
  country_id INTEGER,

  FOREIGN KEY(country_id) REFERENCES country(id)
);

CREATE TABLE countries (
  id INTEGER PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  continent_id INTEGER,

  FOREIGN KEY(continent_id) REFERENCES continent(id)
);

CREATE TABLE continents (
  id INTEGER PRIMARY KEY,
  name VARCHAR(255) NOT NULL
);

INSERT INTO
  continents (id, name)
VALUES
  (1, "Europe"),
  (2, "Asia"),
  (3, "South America"),
  (4, "North America"),
  (5, "Antarctica"),
  (6, "Australia"),
  (7, "Africa");

INSERT INTO
  countries (id, name, continent_id)
VALUES
  (1, "Italy", 1),
  (2, "Japan", 2),
  (3, "Chile", 3),
  (4, "Mexico", 3),
  (5, "Iceland", 1);

INSERT INTO
  volcanoes (id, name, country_id, last_eruption)
VALUES
  (1, "Mount Etna", 1, "December 3, 2015"),
  (2, "Stromboli", 1, "Ongoing"),
  (3, "Vesuvius", 1, "1944"),
  (4, "Fuji", 2, "December 16, 1707"),
  (5, "Cerro Azul", 3, "1967"),
  (6, "Colima", 4, "2015"),
  (7, "Mount Doom", NULL, "Unknown");
