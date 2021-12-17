--
-- PostgreSQL database dump
--

-- Dumped from database version 14.1 (Ubuntu 14.1-2.pgdg20.04+1)
-- Dumped by pg_dump version 14.1 (Ubuntu 14.1-2.pgdg20.04+1)

-- Started on 2021-12-17 13:06:19 CST

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- TOC entry 2 (class 3079 OID 16410)
-- Name: uuid-ossp; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA public;


--
-- TOC entry 3422 (class 0 OID 0)
-- Dependencies: 2
-- Name: EXTENSION "uuid-ossp"; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION "uuid-ossp" IS 'generate universally unique identifiers (UUIDs)';


--
-- TOC entry 242 (class 1255 OID 16421)
-- Name: fetch_latest_clients(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.fetch_latest_clients() RETURNS TABLE(team_id uuid, submission_id integer, file_text character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN
-- Select latest code files. Because of the serial nature of submissionID, we can use max(subid) to 
-- find the latest submission.
RETURN QUERY
SELECT
    sub.team_id,
    sub.submission_id,
    code_file.file_text
from
    code_file
    JOIN (
        SELECT
            submission.team_id,
            MAX(submission.submission_id) as submission_id
        FROM
            submission
        GROUP BY
            submission.team_id
    ) as sub ON sub.submission_id = code_file.submission_id;
end;
$$;


ALTER FUNCTION public.fetch_latest_clients() OWNER TO postgres;

--
-- TOC entry 246 (class 1255 OID 16422)
-- Name: get_file_from_submission(uuid, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_file_from_submission(teamid uuid, submissionid integer) RETURNS character varying
    LANGUAGE plpgsql
    AS $$
BEGIN
-- Select the latest submission_id and group_run_id for a team
RETURN file_text FROM code_file JOIN submission ON code_file.submission_id = submission.submission_id
WHERE team_id = teamid AND submission.submission_id = submissionid;
--SELECT * FROM team
end;
$$;


ALTER FUNCTION public.get_file_from_submission(teamid uuid, submissionid integer) OWNER TO postgres;

--
-- TOC entry 256 (class 1255 OID 16423)
-- Name: get_latest_submission(uuid); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_latest_submission(teamid uuid) RETURNS TABLE(submission_id integer, group_run_id integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
-- Select the latest submission_id and group_run_id for a team
RETURN QUERY
SELECT
    MAX(submission.submission_id),
	MAX(run.group_run_id)
FROM
    run
    JOIN submission ON run.submission_id = submission.submission_id
WHERE submission.team_id = teamid;
--SELECT * FROM team
end;
$$;


ALTER FUNCTION public.get_latest_submission(teamid uuid) OWNER TO postgres;

--
-- TOC entry 257 (class 1255 OID 16424)
-- Name: get_leaderboard(boolean, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_leaderboard(include_inelligible boolean, grouprun integer) RETURNS TABLE(group_run_id integer, team_name character varying, uni_name character varying, submit_time timestamp without time zone, average_score numeric, standard_deviation numeric)
    LANGUAGE plpgsql
    AS $$
BEGIN
-- Created by: Sean Hagen
-- Written on: 11/1/2021
-- include_inelligible: if true, return inelligible teams in the results
-- group_run: if -1 then return most recent group_run, else return results for the specified group run
RETURN QUERY
SELECT
	run.group_run_id,
    team.team_name,
    university.uni_name,
    submission.submit_time,
    ROUND(AVG(run.score), 3) as Average_Score,
    ROUND(stddev_pop(run.score), 3) as Standard_Deviation
FROM
    run
    JOIN submission ON run.submission_id = submission.submission_id
    JOIN team on submission.team_id = team.team_id
    JOIN team_type on team.team_type_id = team_type.team_type_id
    JOIN university on team.uni_id = university.uni_id
WHERE
    (
        team_type.eligible
        OR include_inelligible
    )
    AND (
        -- If grouprun is negative, select most recent grouprun
        run.group_run_id in (
            SELECT
                MAX(group_run.group_run_id)
            FROM
                group_run
        )
        AND grouprun < 0
    )
    OR (
        -- Otherwise, select the specified grouprunF
        run.group_run_id = grouprun
        AND grouprun > 0
    ) -- If include_inelligible is true, all teams are included. Else, the team must be elligible
GROUP BY
    team.team_name,
    university.uni_name,
    submission.submit_time,
	run.group_run_id
ORDER BY
    Average_Score DESC;

end;
$$;


ALTER FUNCTION public.get_leaderboard(include_inelligible boolean, grouprun integer) OWNER TO postgres;

--
-- TOC entry 258 (class 1255 OID 16425)
-- Name: get_runs_for_submission(uuid, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_runs_for_submission(teamid uuid, submissionid integer) RETURNS TABLE(run_id integer, score integer, group_run_id integer, run_time timestamp without time zone, seed_id integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
-- Select the latest submission_id and group_run_id for a team
RETURN QUERY
SELECT run.run_id, run.score, run.group_run_id, run.run_time, run.seed_id  
FROM submission JOIN run ON submission.submission_id = run.submission_id
WHERE submission.team_id = teamid AND submission.submission_id = submissionid
ORDER BY run.run_time DESC;
--SELECT * FROM team
end;
$$;


ALTER FUNCTION public.get_runs_for_submission(teamid uuid, submissionid integer) OWNER TO postgres;

--
-- TOC entry 259 (class 1255 OID 16426)
-- Name: get_stats_for_submission(integer, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_stats_for_submission(submissionid integer, groupid integer) RETURNS TABLE(group_run_id integer, run_id integer, run_time timestamp without time zone, score integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
-- Select the latest submission_id and group_run_id for a team
RETURN QUERY
SELECT run.group_run_id, run.run_id, run.run_time, run.score FROM run JOIN submission ON run.submission_id = submission.submission_id
WHERE run.submission_id = submissionid AND run.group_run_id = groupid;
--SELECT * FROM team
end;
$$;


ALTER FUNCTION public.get_stats_for_submission(submissionid integer, groupid integer) OWNER TO postgres;

--
-- TOC entry 260 (class 1255 OID 16427)
-- Name: get_submissions_for_team(uuid); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_submissions_for_team(teamid uuid) RETURNS TABLE(submission_id integer, submit_time timestamp without time zone)
    LANGUAGE plpgsql
    AS $$
BEGIN
-- Select the latest submission_id and group_run_id for a team
RETURN QUERY
SELECT submission.submission_id, submission.submit_time FROM SUBMISSION 
WHERE team_id = teamid
ORDER BY submit_time DESC;
--SELECT * FROM team
end;
$$;


ALTER FUNCTION public.get_submissions_for_team(teamid uuid) OWNER TO postgres;

--
-- TOC entry 261 (class 1255 OID 16428)
-- Name: get_team_score_over_time(uuid); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_team_score_over_time(teamid uuid) RETURNS TABLE(group_run_id integer, run_time timestamp without time zone, average_score numeric, standard_deviation numeric)
    LANGUAGE plpgsql
    AS $$
BEGIN
-- Selects all teams
RETURN QUERY
SELECT
	run.group_run_id,
	group_run.start_run as run_time,
    ROUND(AVG(run.score),3) as Average_Score,
	ROUND(stddev_pop(run.score),3) as Standard_Deviation
FROM
    run
    JOIN submission ON run.submission_id = submission.submission_id
	JOIN group_run ON run.group_run_id = group_run.group_run_id
WHERE
	submission.team_id = teamId
GROUP BY run.group_run_id, group_run.start_run
ORDER BY group_run.start_run DESC;
end;
$$;


ALTER FUNCTION public.get_team_score_over_time(teamid uuid) OWNER TO postgres;

--
-- TOC entry 262 (class 1255 OID 16429)
-- Name: get_team_types(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_team_types() RETURNS TABLE(team_type_id integer, team_type_name character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN
-- Selects all team types
RETURN QUERY
SELECT team_type.team_type_id, team_type.team_type_name FROM team_type;
end;
$$;


ALTER FUNCTION public.get_team_types() OWNER TO postgres;

--
-- TOC entry 263 (class 1255 OID 16430)
-- Name: get_teams(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_teams() RETURNS TABLE(team_name character varying, uni_name character varying, team_type_name character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN
-- Selects all teams
RETURN QUERY
SELECT team.team_name, university.uni_name, team_type.team_type_name FROM team 
JOIN university ON team.uni_id = university.uni_id 
JOIN team_type ON team.team_type_id = team_type.team_type_id;
end;
$$;


ALTER FUNCTION public.get_teams() OWNER TO postgres;

--
-- TOC entry 236 (class 1255 OID 16431)
-- Name: get_universities(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_universities() RETURNS TABLE(uni_id integer, uni_name character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN
-- Selects all universities
RETURN QUERY
SELECT university.uni_id, university.uni_name FROM university;
end;
$$;


ALTER FUNCTION public.get_universities() OWNER TO postgres;

--
-- TOC entry 237 (class 1255 OID 16432)
-- Name: insert_group_run(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.insert_group_run() RETURNS integer
    LANGUAGE plpgsql
    AS $$
DECLARE rtnid integer;
BEGIN
-- Insert into group run. both id and timestamp are default, so no parameters
    INSERT INTO group_run DEFAULT VALUES RETURNING group_run_id INTO rtnid;
	return rtnid;
end;
$$;


ALTER FUNCTION public.insert_group_run() OWNER TO postgres;

--
-- TOC entry 241 (class 1255 OID 16643)
-- Name: insert_group_run(character varying); Type: FUNCTION; Schema: public; Owner: byte_api
--

CREATE FUNCTION public.insert_group_run(launcherversion character varying) RETURNS integer
    LANGUAGE plpgsql
    AS $$
DECLARE rtnid integer;
BEGIN
-- Insert into group run. both id and timestamp are default, so no parameters
    INSERT INTO group_run(launcher_version) VALUES (LauncherVersion) RETURNING group_run_id INTO rtnid;
	return rtnid;
end;
$$;


ALTER FUNCTION public.insert_group_run(launcherversion character varying) OWNER TO byte_api;

--
-- TOC entry 238 (class 1255 OID 16433)
-- Name: insert_run(integer, integer, integer, character varying, integer); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.insert_run(IN sub_id integer, IN score integer, IN group_run_id integer, IN err character varying, IN seedid integer)
    LANGUAGE plpgsql
    AS $$
DECLARE runid int;
begin
    -- insert run into run table
	INSERT INTO run(submission_id, score, group_run_id, seed_id) 
	VALUES (sub_id, score, group_run_id, seedid) RETURNING run_id INTO runid;
	
	if err <> '' then
		INSERT INTO errors VALUES (runid, err);
	end if;
end;
$$;


ALTER PROCEDURE public.insert_run(IN sub_id integer, IN score integer, IN group_run_id integer, IN err character varying, IN seedid integer) OWNER TO postgres;

--
-- TOC entry 239 (class 1255 OID 16434)
-- Name: insert_seed(character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.insert_seed(seedfl character varying) RETURNS integer
    LANGUAGE plpgsql
    AS $$
DECLARE rtnid integer;
BEGIN
-- Insert into group run. both id and timestamp are default, so no parameters
    INSERT INTO seed (seed) VALUES (seedfl) RETURNING seed_id INTO rtnid;
	return rtnid;
end;
$$;


ALTER FUNCTION public.insert_seed(seedfl character varying) OWNER TO postgres;

--
-- TOC entry 240 (class 1255 OID 16435)
-- Name: insert_team(integer, character varying, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.insert_team(team_type integer, team character varying, uni integer) RETURNS uuid
    LANGUAGE plpgsql
    AS $$
DECLARE tmid uuid;
BEGIN
-- Insert into team
    INSERT INTO team (team_type_id, team_name, uni_id) VALUES (team_type, team, uni)  RETURNING team_id INTO tmid;
	return tmid;
end;
$$;


ALTER FUNCTION public.insert_team(team_type integer, team character varying, uni integer) OWNER TO postgres;

--
-- TOC entry 253 (class 1255 OID 16436)
-- Name: submit_code_file(character varying, uuid); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.submit_code_file(IN file character varying, IN vid uuid)
    LANGUAGE plpgsql
    AS $$
DECLARE sub_ID int = 0;
begin
    -- insert submission into submission table
	INSERT INTO SUBMISSION (team_id) VALUES (vid) RETURNING submission_id INTO sub_ID;
	
    -- insert file into file table
	INSERT INTO code_file(submission_id, file_text) VALUES (sub_id, file);
end;
$$;


ALTER PROCEDURE public.submit_code_file(IN file character varying, IN vid uuid) OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 210 (class 1259 OID 16437)
-- Name: code_file; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.code_file (
    submission_id integer,
    file_text character varying
);


ALTER TABLE public.code_file OWNER TO postgres;

--
-- TOC entry 211 (class 1259 OID 16442)
-- Name: errors; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.errors (
    run_id integer,
    error_text character varying
);


ALTER TABLE public.errors OWNER TO postgres;

--
-- TOC entry 212 (class 1259 OID 16447)
-- Name: group_run; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.group_run (
    group_run_id integer NOT NULL,
    start_run timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    launcher_version character varying(10) NOT NULL
);


ALTER TABLE public.group_run OWNER TO postgres;

--
-- TOC entry 213 (class 1259 OID 16451)
-- Name: group_run_group_run_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.group_run_group_run_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.group_run_group_run_id_seq OWNER TO postgres;

--
-- TOC entry 3423 (class 0 OID 0)
-- Dependencies: 213
-- Name: group_run_group_run_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.group_run_group_run_id_seq OWNED BY public.group_run.group_run_id;


--
-- TOC entry 214 (class 1259 OID 16452)
-- Name: logs; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.logs (
    run_id integer,
    log_text character varying
);


ALTER TABLE public.logs OWNER TO postgres;

--
-- TOC entry 215 (class 1259 OID 16457)
-- Name: run; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.run (
    submission_id integer,
    run_id integer NOT NULL,
    score integer,
    group_run_id integer,
    run_time timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    seed_id integer
);


ALTER TABLE public.run OWNER TO postgres;

--
-- TOC entry 216 (class 1259 OID 16461)
-- Name: run_runid_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.run_runid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.run_runid_seq OWNER TO postgres;

--
-- TOC entry 3424 (class 0 OID 0)
-- Dependencies: 216
-- Name: run_runid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.run_runid_seq OWNED BY public.run.run_id;


--
-- TOC entry 217 (class 1259 OID 16462)
-- Name: seed; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.seed (
    seed_id integer NOT NULL,
    seed character varying
);


ALTER TABLE public.seed OWNER TO postgres;

--
-- TOC entry 218 (class 1259 OID 16467)
-- Name: seed_seed_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seed_seed_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.seed_seed_id_seq OWNER TO postgres;

--
-- TOC entry 3425 (class 0 OID 0)
-- Dependencies: 218
-- Name: seed_seed_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.seed_seed_id_seq OWNED BY public.seed.seed_id;


--
-- TOC entry 219 (class 1259 OID 16468)
-- Name: submission; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.submission (
    team_id uuid,
    submission_id integer NOT NULL,
    valid boolean DEFAULT false NOT NULL,
    submit_time timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.submission OWNER TO postgres;

--
-- TOC entry 220 (class 1259 OID 16473)
-- Name: submission_submissionid_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.submission_submissionid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.submission_submissionid_seq OWNER TO postgres;

--
-- TOC entry 3426 (class 0 OID 0)
-- Dependencies: 220
-- Name: submission_submissionid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.submission_submissionid_seq OWNED BY public.submission.submission_id;


--
-- TOC entry 221 (class 1259 OID 16474)
-- Name: team; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.team (
    team_id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    uni_id integer,
    team_type_id integer,
    team_name character varying(100) NOT NULL,
    CONSTRAINT team_teamname_check CHECK (((team_name)::text <> ''::text))
);


ALTER TABLE public.team OWNER TO postgres;

--
-- TOC entry 222 (class 1259 OID 16479)
-- Name: team_type; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.team_type (
    team_type_id integer NOT NULL,
    team_type_name character varying(100) NOT NULL,
    eligible boolean,
    CONSTRAINT teamtype_teamname_check CHECK (((team_type_name)::text <> ''::text))
);


ALTER TABLE public.team_type OWNER TO postgres;

--
-- TOC entry 223 (class 1259 OID 16483)
-- Name: teamtype_teamtypeid_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.teamtype_teamtypeid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.teamtype_teamtypeid_seq OWNER TO postgres;

--
-- TOC entry 3427 (class 0 OID 0)
-- Dependencies: 223
-- Name: teamtype_teamtypeid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.teamtype_teamtypeid_seq OWNED BY public.team_type.team_type_id;


--
-- TOC entry 224 (class 1259 OID 16484)
-- Name: university; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.university (
    uni_id integer NOT NULL,
    uni_name character varying(100) NOT NULL,
    CONSTRAINT university_uniname_check CHECK (((uni_name)::text <> ''::text))
);


ALTER TABLE public.university OWNER TO postgres;

--
-- TOC entry 225 (class 1259 OID 16488)
-- Name: university_uniid_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.university_uniid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.university_uniid_seq OWNER TO postgres;

--
-- TOC entry 3428 (class 0 OID 0)
-- Dependencies: 225
-- Name: university_uniid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.university_uniid_seq OWNED BY public.university.uni_id;


--
-- TOC entry 3240 (class 2604 OID 16489)
-- Name: group_run group_run_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.group_run ALTER COLUMN group_run_id SET DEFAULT nextval('public.group_run_group_run_id_seq'::regclass);


--
-- TOC entry 3242 (class 2604 OID 16490)
-- Name: run run_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.run ALTER COLUMN run_id SET DEFAULT nextval('public.run_runid_seq'::regclass);


--
-- TOC entry 3243 (class 2604 OID 16491)
-- Name: seed seed_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.seed ALTER COLUMN seed_id SET DEFAULT nextval('public.seed_seed_id_seq'::regclass);


--
-- TOC entry 3246 (class 2604 OID 16492)
-- Name: submission submission_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.submission ALTER COLUMN submission_id SET DEFAULT nextval('public.submission_submissionid_seq'::regclass);


--
-- TOC entry 3249 (class 2604 OID 16493)
-- Name: team_type team_type_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.team_type ALTER COLUMN team_type_id SET DEFAULT nextval('public.teamtype_teamtypeid_seq'::regclass);


--
-- TOC entry 3251 (class 2604 OID 16494)
-- Name: university uni_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.university ALTER COLUMN uni_id SET DEFAULT nextval('public.university_uniid_seq'::regclass);


--
-- TOC entry 3254 (class 2606 OID 16496)
-- Name: group_run group_run_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.group_run
    ADD CONSTRAINT group_run_pkey PRIMARY KEY (group_run_id);


--
-- TOC entry 3256 (class 2606 OID 16498)
-- Name: run run_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.run
    ADD CONSTRAINT run_pkey PRIMARY KEY (run_id);


--
-- TOC entry 3258 (class 2606 OID 16500)
-- Name: seed seed_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.seed
    ADD CONSTRAINT seed_pkey PRIMARY KEY (seed_id);


--
-- TOC entry 3260 (class 2606 OID 16502)
-- Name: submission submission_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.submission
    ADD CONSTRAINT submission_pkey PRIMARY KEY (submission_id);


--
-- TOC entry 3262 (class 2606 OID 16504)
-- Name: team team_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.team
    ADD CONSTRAINT team_pkey PRIMARY KEY (team_id);


--
-- TOC entry 3264 (class 2606 OID 16506)
-- Name: team team_teamname_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.team
    ADD CONSTRAINT team_teamname_key UNIQUE (team_name);


--
-- TOC entry 3266 (class 2606 OID 16508)
-- Name: team_type teamtype_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.team_type
    ADD CONSTRAINT teamtype_pkey PRIMARY KEY (team_type_id);


--
-- TOC entry 3268 (class 2606 OID 16510)
-- Name: university university_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.university
    ADD CONSTRAINT university_pkey PRIMARY KEY (uni_id);


--
-- TOC entry 3269 (class 2606 OID 16511)
-- Name: code_file codefile_submissionid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.code_file
    ADD CONSTRAINT codefile_submissionid_fkey FOREIGN KEY (submission_id) REFERENCES public.submission(submission_id);


--
-- TOC entry 3270 (class 2606 OID 16516)
-- Name: errors errors_run_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.errors
    ADD CONSTRAINT errors_run_id_fkey FOREIGN KEY (run_id) REFERENCES public.run(run_id);


--
-- TOC entry 3271 (class 2606 OID 16521)
-- Name: logs logs_runid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.logs
    ADD CONSTRAINT logs_runid_fkey FOREIGN KEY (run_id) REFERENCES public.submission(submission_id);


--
-- TOC entry 3272 (class 2606 OID 16526)
-- Name: run run_group_run_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.run
    ADD CONSTRAINT run_group_run_id_fkey FOREIGN KEY (group_run_id) REFERENCES public.group_run(group_run_id);


--
-- TOC entry 3273 (class 2606 OID 16531)
-- Name: run run_submissionid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.run
    ADD CONSTRAINT run_submissionid_fkey FOREIGN KEY (submission_id) REFERENCES public.submission(submission_id);


--
-- TOC entry 3274 (class 2606 OID 16536)
-- Name: run seed_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.run
    ADD CONSTRAINT seed_fk FOREIGN KEY (seed_id) REFERENCES public.seed(seed_id);


--
-- TOC entry 3275 (class 2606 OID 16541)
-- Name: submission submission_teamid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.submission
    ADD CONSTRAINT submission_teamid_fkey FOREIGN KEY (team_id) REFERENCES public.team(team_id);


--
-- TOC entry 3276 (class 2606 OID 16546)
-- Name: team team_teamtypeid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.team
    ADD CONSTRAINT team_teamtypeid_fkey FOREIGN KEY (team_type_id) REFERENCES public.team_type(team_type_id);


--
-- TOC entry 3277 (class 2606 OID 16551)
-- Name: team team_uniid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.team
    ADD CONSTRAINT team_uniid_fkey FOREIGN KEY (uni_id) REFERENCES public.university(uni_id);


-- Completed on 2021-12-17 13:06:19 CST

--
-- PostgreSQL database dump complete
--

