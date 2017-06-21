use hospital_warehouse;

DROP VIEW hospital_complications_ratings;
CREATE VIEW hospital_complications_ratings (state, total_score, percentage_rated, ratings_count, percentage_worse,
		percentage_same, percentage_better, bad_marks, good_marks, great_marks)
	AS
	select loc.state,
		(
			(((
				SUM(CASE WHEN m.relative_to_natl_avg = 'SAME' THEN 1 ELSE 0 END) /
				SUM(m.relative_to_natl_avg = 'SAME' OR m.relative_to_natl_avg = 'BETTER' OR m.relative_to_natl_avg = 'WORSE') 
			) +
			(
				SUM(CASE WHEN m.relative_to_natl_avg = 'BETTER' THEN 3 ELSE 0 END) /
				SUM(m.relative_to_natl_avg = 'SAME' OR m.relative_to_natl_avg = 'BETTER' OR m.relative_to_natl_avg = 'WORSE')
			) -
			(
				SUM(CASE WHEN m.relative_to_natl_avg = 'WORSE' THEN 2 ELSE 0 END) /
				SUM(m.relative_to_natl_avg = 'SAME' OR m.relative_to_natl_avg = 'BETTER' OR m.relative_to_natl_avg = 'WORSE')
			)) * 1000 - 350) 
		) AS total_score,
		(ROUND(
			SUM(
				CASE
					WHEN m.relative_to_natl_avg = 'WORSE' THEN 1
					WHEN m.relative_to_natl_avg = 'SAME' THEN 1
					WHEN m.relative_to_natl_avg = 'BETTER' THEN 1
					ELSE 0
				END
			) /
		   sum(1) * 100, 2)
		) AS percentage_rated,
		SUM(
			CASE
				WHEN m.relative_to_natl_avg = 'WORSE' THEN 1
				WHEN m.relative_to_natl_avg = 'SAME' THEN 1
				WHEN m.relative_to_natl_avg = 'BETTER' THEN 1
				ELSE 0
			END
		) AS ratings_count,
		(ROUND((
				SUM(CASE WHEN m.relative_to_natl_avg = 'WORSE' THEN 1 ELSE 0 END) /
				SUM(m.relative_to_natl_avg = 'SAME' OR m.relative_to_natl_avg = 'BETTER' OR m.relative_to_natl_avg = 'WORSE')
			* 100), 2)
		) AS percentage_worse,
		(ROUND((
				SUM(CASE WHEN m.relative_to_natl_avg = 'SAME' THEN 1 ELSE 0 END) /
				SUM(m.relative_to_natl_avg = 'SAME' OR m.relative_to_natl_avg = 'BETTER' OR m.relative_to_natl_avg = 'WORSE')
			 * 100), 2)
		) AS percentage_same,
		(ROUND((
				SUM(CASE WHEN m.relative_to_natl_avg = 'BETTER' THEN 1 ELSE 0 END) /
				SUM(m.relative_to_natl_avg = 'SAME' OR m.relative_to_natl_avg = 'BETTER' OR m.relative_to_natl_avg = 'WORSE')
			* 100), 2)
		) AS percentage_better,
		SUM(CASE WHEN m.relative_to_natl_avg = 'WORSE' THEN 1 ELSE 0 END) AS bad_marks,
		SUM(CASE WHEN m.relative_to_natl_avg = 'SAME' THEN 1 ELSE 0 END) AS good_marks,
		SUM(CASE WHEN m.relative_to_natl_avg = 'BETTER' THEN 1 ELSE 0 END) AS great_marks
	from measure m
		INNER JOIN hospital h
		ON m.hospital_id = h.id
		INNER JOIN location loc
		ON h.location_id = loc.id
		INNER JOIN measure_type mt
		ON m.measure_type_id = mt.id
	GROUP BY loc.state;
    
SELECT * FROM hospital_complications_ratings
WHERE total_score IS NOT NULL AND percentage_rated >= 15
ORDER BY total_score DESC, percentage_rated DESC; 