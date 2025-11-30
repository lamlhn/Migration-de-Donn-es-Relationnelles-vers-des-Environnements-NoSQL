
-- SCRIPT CYPHER POUR IMPORT NEO4J
-- Étape 3: Migration des données Neo4j

-- 1. Création des contraintes
CREATE CONSTRAINT customer_id IF NOT EXISTS FOR (c:Customer) REQUIRE c.customerId IS UNIQUE;
CREATE CONSTRAINT film_id IF NOT EXISTS FOR (f:Film) REQUIRE f.filmId IS UNIQUE;
CREATE CONSTRAINT category_id IF NOT EXISTS FOR (cat:Category) REQUIRE cat.categoryId IS UNIQUE;
CREATE CONSTRAINT staff_id IF NOT EXISTS FOR (s:Staff) REQUIRE s.staffId IS UNIQUE;

-- 2. Import des nœuds Customer
LOAD CSV WITH HEADERS FROM 'file:///customers.csv' AS row
CREATE (c:Customer {
    customerId: toInteger(row.customerId),
    firstName: row.firstName,
    lastName: row.lastName,
    email: row.email,
    joinDate: datetime(row.joinDate)
});

-- 3. Import des nœuds Film
LOAD CSV WITH HEADERS FROM 'file:///films.csv' AS row
CREATE (f:Film {
    filmId: toInteger(row.filmId),
    title: row.title,
    releaseYear: toInteger(row.releaseYear),
    rating: row.rating,
    rentalRate: toFloat(row.rentalRate)
});

-- 4. Import des nœuds Category
LOAD CSV WITH HEADERS FROM 'file:///categories.csv' AS row
CREATE (cat:Category {
    categoryId: toInteger(row.categoryId),
    categoryName: row.categoryName
});

-- 5. Import des nœuds Staff
LOAD CSV WITH HEADERS FROM 'file:///staff.csv' AS row
CREATE (s:Staff {
    staffId: toInteger(row.staffId),
    firstName: row.firstName,
    lastName: row.lastName,
    email: row.email,
    storeId: toInteger(row.storeId)
});

-- 6. Création des relations WATCHED
LOAD CSV WITH HEADERS FROM 'file:///watched_relations.csv' AS row
MATCH (c:Customer {customerId: toInteger(row[":START_ID(Customer)"])})
MATCH (f:Film {filmId: toInteger(row[":END_ID(Film)"])})
CREATE (c)-[:WATCHED {rentalDate: datetime(row.rentalDate)}]->(f);

-- 7. Création des relations IN_CATEGORY
LOAD CSV WITH HEADERS FROM 'file:///film_category_relations.csv' AS row
MATCH (f:Film {filmId: toInteger(row[":START_ID(Film)"])})
MATCH (cat:Category {categoryId: toInteger(row[":END_ID(Category)"])})
CREATE (f)-[:IN_CATEGORY]->(cat);

-- 8. Création des relations REPORTS_TO
LOAD CSV WITH HEADERS FROM 'file:///staff_hierarchy.csv' AS row
MATCH (s1:Staff {staffId: toInteger(row[":START_ID(Staff)"])})
MATCH (s2:Staff {staffId: toInteger(row[":END_ID(Staff)"])})
CREATE (s1)-[:REPORTS_TO]->(s2);

-- 9. Validation des imports
MATCH (n) RETURN labels(n) as label, count(*) as count
ORDER BY label;
