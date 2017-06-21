use hospital_warehouse;

-- select h.full_name, m.relative_to_natl_avg
-- from hospital h
-- inner join measure m
-- where m.relative_to_natl_avg = 'BETTER'
-- and h.id = m.hospital_id;

-- drop function is_bad_mark;
-- CREATE FUNCTION is_bad_mark (relative_to_avg VARCHAR(55))
-- 	RETURNS TINYINT
--     RETURN (
-- 		CASE
-- 			WHEN m.relative_to_natl_avg = 'WORSE' THEN 1
--             ELSE 0
-- 		END
--     );
--     
-- drop function is_good_mark;
-- CREATE FUNCTION is_good_mark (relative_to_avg VARCHAR(55))
-- 	RETURNS TINYINT
--     RETURN (
-- 		CASE
-- 			WHEN m.relative_to_natl_avg = 'BETTER' THEN 1
--             ELSE 0
--         END
--     );
-- 


select loc.state,
	(
		ROUND((
			SUM(CASE WHEN m.relative_to_natl_avg = 'SAME' THEN 1 ELSE 0 END) /
            SUM(m.relative_to_natl_avg = 'SAME' OR m.relative_to_natl_avg = 'BETTER' OR m.relative_to_natl_avg = 'WORSE') 
		) +
        (
			SUM(CASE WHEN m.relative_to_natl_avg = 'BETTER' THEN 2 ELSE 0 END) /
            SUM(m.relative_to_natl_avg = 'SAME' OR m.relative_to_natl_avg = 'BETTER' OR m.relative_to_natl_avg = 'WORSE')
		) -
        (
			SUM(CASE WHEN m.relative_to_natl_avg = 'WORSE' THEN 1 ELSE 0 END) /
            SUM(m.relative_to_natl_avg = 'SAME' OR m.relative_to_natl_avg = 'BETTER' OR m.relative_to_natl_avg = 'WORSE')
		) * 100, 4)
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
	-- WHERE m.relative_to_natl_avg = 'SAME' OR m.relative_to_natl_avg = 'BETTER' OR m.relative_to_natl_avg = 'WORSE'
GROUP BY loc.state
ORDER BY total_score DESC, percentage_rated DESC; 