-- Creating bridge table between of title and genre
MERGE INTO MID_TERM_DADABI.IMDB_SCHEMA.BRIDGE_TITLE_GENRE AS t
USING (SELECT c.title_sk, b.genre_sk
        FROM MID_TERM_DADABI.FLATTEN_SCHEMA.TITLE_BASICS_GENRES a
        LEFT JOIN MID_TERM_DADABI.IMDB_SCHEMA.DIM_GENRE b ON a.genre = b.genre
        LEFT JOIN MID_TERM_DADABI.imdb_schema.dim_title c ON a.tconst = c.tconst) AS s    
ON t.title_sk = s.title_sk and t.genre_sk = s.genre_sk 
WHEN NOT MATCHED THEN 
INSERT (TITLE_SK, GENRE_SK, DI_LOAD_DT)
VALUES (s.title_sk, s.genre_sk, current_date());

-- Creating akas table
CREATE OR REPLACE SEQUENCE AKAS_DIM_DETAIL;

MERGE INTO MID_TERM_DADABI.IMDB_SCHEMA.DIM_AKAS_DETAILS AS t
USING (SELECT DISTINCT b.title_sk, a.REGION, a.LANGUAGE
        FROM MID_TERM_DADABI.RAW_STAGE_SCHEMA.TITLE_AKAS a
        INNER JOIN MID_TERM_DADABI.IMDB_SCHEMA.DIM_TITLE b ON a.titleid = b.tconst) AS s    
ON t.TITLE_SK = s.TITLE_SK and T.REGION = S.REGION and T.LANGUAGE = s.LANGUAGE
WHEN NOT MATCHED THEN 
INSERT (AKAS_SK, TITLE_SK, REGION, LANGUAGE, DI_LOAD_DT)
VALUES (AKAS_DIM_DETAIL.nextVal, s.title_sk, s.region, s.language, current_date());

-- Create Fact Title Details table
MERGE INTO MID_TERM_DADABI.IMDB_SCHEMA.FCT_TITLE_DETAILS AS tgt
USING (SELECT dt.title_sk, dp.person_sk, dprof.profession_sk, dc.character_sk, dj.job_sk 
    FROM MID_TERM_DADABI.RAW_STAGE_SCHEMA.TITLE_PRINCIPALS tp
    INNER JOIN DIM_TITLE dt on dt.tconst = tp.tconst
    INNER JOIN DIM_PERSON dp on tp.nconst = dp.nconst
    INNER JOIN FLATTEN_SCHEMA.NAME_BASICS_PRIMARY_PROFESSION pp on pp.nconst = tp.nconst
    INNER JOIN DIM_PROFESSION dprof on dprof.profession_name = pp.primaryprofession
    inner JOIN DIM_CHARACTERS dc on dc.character_name = tp.characters
    INNER JOIN DIM_JOB dj on dj.job_name = tp.job
) s
ON tgt.title_sk = s.title_sk AND tgt.person_sk = s.person_sk AND tgt.profession_sk = s.profession_sk AND tgt.character_sk = s.character_sk AND tgt.job_sk = s.job_sk
WHEN NOT MATCHED THEN
INSERT (TITLE_DETAILS_SK, TITLE_SK, person_sk, profession_sk, character_sk, job_sk, di_load_dt)
VALUES (FCT_TITLE_DETAIL.nextVal, s.title_sk, s.person_sk, s.profession_sk, s.character_sk, s.job_sk, current_date());

-- Create Fact Title Metrics table
MERGE INTO MID_TERM_DADABI.IMDB_SCHEMA.FCT_TITLE_METRICS AS tgt
USING (SELECT dt.title_sk, tb.runtimeminutes, IFNULL(tr.averagerating, -1) as AVERAGERATING, IFNULL(te.seasonnumber, -1) as seasonnumber, COUNT(te.episodenumber) as COUNT_OF_EPISODES
    FROM MID_TERM_DADABI.RAW_STAGE_SCHEMA.TITLE_BASICS tb
    inner JOIN DIM_TITLE dt on dt.tconst = tb.tconst
    LEFT JOIN RAW_STAGE_SCHEMA.TITLE_EPISODE te on te.parenttconst = tb.tconst
    LEFT JOIN RAW_STAGE_SCHEMA.TITLE_RATINGS tr on tr.tconst = tb.tconst
GROUP BY ALL
) s
ON tgt.title_sk = s.title_sk AND tgt.runtime_minutes = s.runtimeminutes AND tgt.average_rating = s.averagerating AND tgt.season_number = s.seasonnumber AND tgt.COUNT_OF_EPISODES = s.COUNT_OF_EPISODES
WHEN NOT MATCHED THEN
INSERT (TITLE_METRICS_SK, TITLE_SK, RUNTIME_MINUTES, AVERAGE_RATING, SEASON_NUMBER, COUNT_OF_EPISODES, di_load_dt)
VALUES (FCT_TITLE_METRICS.nextVal, s.title_sk, s.runtimeminutes, s.averagerating, s.seasonnumber, s.COUNT_OF_EPISODES, current_date());
