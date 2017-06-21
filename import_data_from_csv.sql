USE hospital_warehouse;

DROP TABLE complications_hospital;

CREATE TABLE complications_hospital (
		id MEDIUMINT UNSIGNED NOT NULL AUTO_INCREMENT,
		provider_id MEDIUMINT UNSIGNED NOT NULL,
        hospital_name VARCHAR(100) NOT NULL,
        address VARCHAR(255),
        city VARCHAR(100),
        state CHAR(2),
        zip_code CHAR(5),
        county_name VARCHAR(100),
        phone_number CHAR(10),
        measure_name VARCHAR(355),
        measure_id VARCHAR(30) NOT NULL,
        compared_to_national VARCHAR(55),
        denominator MEDIUMINT NULL,
        score FLOAT(7, 2) NULL,
        lower_estimate FLOAT(7, 2) NULL,
        higher_estimate FLOAT(7, 2) NULL,
        footnote VARCHAR(200) NULL,
        measure_start_date DATE NOT NULL,
        measure_end_date DATE NOT NULL,
        PRIMARY KEY (id)
);

DELETE FROM complications_hospital;

SET @EMPTY_VALUE = "Not Available";

LOAD DATA LOCAL INFILE '~/Downloads/Hospital_Revised_Flatfiles/Complications_Hospital.csv'
INTO TABLE complications_hospital
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
	(provider_id, hospital_name, address, city, state, zip_code, county_name, phone_number,
		measure_name, measure_id, compared_to_national, @denominator, @score, @lower_estimate,
        @higher_estimate, footnote, @measure_start_date, @measure_end_date)
	SET measure_start_date = STR_TO_DATE(@measure_start_date, '%m/%d/%Y'), 
			measure_end_date = STR_TO_DATE(@measure_end_date, '%m/%d/%Y'),
            denominator = NULLIF(TRIM(@denominator), @EMPTY_VALUE),
            score = NULLIF(TRIM(@score), @EMPTY_VALUE),
            lower_estimate = NULLIF(TRIM(@lower_estimate), @EMPTY_VALUE),
            higher_estimate = NULLIF(TRIM(@higher_estimate), @EMPTY_VALUE);
