USE hospital_warehouse;

set global max_allowed_packet=268435456;
-- 
-- DROP TABLE location;
DROP TABLE hospital;

-- CREATE TABLE location (
-- 	id MEDIUMINT UNSIGNED NOT NULL AUTO_INCREMENT,
--     street_address VARCHAR(255) NOT NULL,
--     city VARCHAR(100),
--     county VARCHAR(100),
--     state CHAR(2),
--     zip_code CHAR(5),
--     PRIMARY KEY (id)
-- );
-- -- 
-- drop table hospital;
CREATE TABLE hospital (
	id MEDIUMINT UNSIGNED NOT NULL AUTO_INCREMENT,
    full_name VARCHAR(100) NULL,
    provider_id MEDIUMINT UNSIGNED NOT NULL,
    location_id MEDIUMINT UNSIGNED NOT NULL,
    phone_number CHAR(10),
    PRIMARY KEY (id)
);
-- 
-- INSERT INTO location (street_address, city, county, state, zip_code)
-- 	SELECT DISTINCT ch.address, ch.city, ch.county_name, ch.state, ch.zip_code
--     FROM complications_hospital ch;
--     
INSERT INTO hospital (full_name, location_id, provider_id, phone_number)
	SELECT DISTINCT ch.hospital_name, loc.id, ch.provider_id, ch.phone_number
    FROM location loc
		RIGHT OUTER JOIN complications_hospital ch
		ON loc.street_address = ch.address; 
-- 
--  SELECT * from hospital;
-- drop table measure_type;
-- CREATE TABLE measure_type (
-- 	id MEDIUMINT UNSIGNED NOT NULL AUTO_INCREMENT,
--     full_name VARCHAR(255) NOT NULL,
--     short_name VARCHAR(30) UNIQUE NOT NULL,
--     PRIMARY KEY (id),
--     INDEX (short_name)
-- );
drop table measure;
CREATE TABLE measure (
	id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    hospital_id MEDIUMINT UNSIGNED NOT NULL,
    measure_type_id MEDIUMINT UNSIGNED NOT NULL,
    denominator MEDIUMINT NULL,
    score FLOAT(7, 2) NULL,
    lower_estimate FLOAT(7, 2) NULL,
    higher_estimate FLOAT(7, 2) NULL,
    relative_to_natl_avg ENUM('WORSE', 'SAME', 'BETTER', 'INSUFFICIENT_DATA', 'NONE', 'UNKNOWN'),
    footnote VARCHAR(200) NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    PRIMARY KEY (id)
);
-- 

-- INSERT INTO measure_type (full_name, short_name)
-- 	SELECT DISTINCT ch.measure_name, ch.measure_id
--     FROM complications_hospital ch;

-- drop function convert_to_rating;
-- CREATE FUNCTION convert_to_rating (comparison_text VARCHAR(55) )
-- 	RETURNS VARCHAR(20) DETERMINISTIC
--     RETURN (
-- 		CASE
-- 			WHEN comparison_text = "Worse than the National Rate" THEN "WORSE"
--             WHEN comparison_text = "No Different than the National Rate" THEN "SAME"
--             WHEN comparison_text = "Better than the National Rate" THEN "BETTER"
--             WHEN comparison_text = "Number of Cases Too Small" THEN "INSUFFICIENT_DATA"
--             WHEN comparison_text = "Not Available" THEN "NONE"
--             ELSE "UNKNOWN"
--         END
--     );

INSERT INTO measure (hospital_id, measure_type_id, denominator, score, lower_estimate, higher_estimate,
		relative_to_natl_avg, footnote, start_date, end_date)
	SELECT h.id, mt.id, ch.denominator, ch.score, ch.lower_estimate, ch.higher_estimate,
		convert_to_rating(ch.compared_to_national), ch.footnote, ch.measure_start_date, ch.measure_end_date
	FROM hospital h
	INNER JOIN complications_hospital ch
	ON h.provider_id = ch.provider_id
	INNER JOIN measure_type mt
	ON mt.short_name = ch.measure_id;

select * from measure_type;
select * from measure;