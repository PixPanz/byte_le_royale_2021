--
-- PostgreSQL database dump
--

-- Dumped from database version 13.4
-- Dumped by pg_dump version 13.4

-- Started on 2021-10-17 18:29:37

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'WIN1256';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- TOC entry 2 (class 3079 OID 17325)
-- Name: uuid-ossp; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA public;


--
-- TOC entry 3072 (class 0 OID 0)
-- Dependencies: 2
-- Name: EXTENSION "uuid-ossp"; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION "uuid-ossp" IS 'generate universally unique identifiers (UUIDs)';


--
-- TOC entry 236 (class 1255 OID 17378)
-- Name: fetch_latest_clients(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.fetch_latest_clients() RETURNS TABLE(teamid uuid, submissionid integer, filetext character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN
-- Select latest code files. Because of the serial nature of submissionID, we can use max(subid) to 
-- find the latest submission.
RETURN QUERY
SELECT
    sub.teamid,
    sub.submissionid,
    codefile.filetext
from
    codefile
    JOIN (
        SELECT
            submission.teamid,
            MAX(submission.submissionid) as submissionid
        FROM
            submission
        GROUP BY
            submission.teamid
    ) as sub ON sub.submissionid = codefile.submissionid;
end;
$$;


ALTER FUNCTION public.fetch_latest_clients() OWNER TO postgres;

--
-- TOC entry 237 (class 1255 OID 17398)
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
-- TOC entry 239 (class 1255 OID 17400)
-- Name: insert_run(integer, integer, integer); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.insert_run(submid integer, score integer, grouprunid integer)
    LANGUAGE plpgsql
    AS $$
begin
    -- insert run into run table
	INSERT INTO run(submissionid, score, group_run_id) VALUES (submid, score, grouprunid);
end;
$$;


ALTER PROCEDURE public.insert_run(submid integer, score integer, grouprunid integer) OWNER TO postgres;

--
-- TOC entry 235 (class 1255 OID 17376)
-- Name: insert_team(integer, character varying, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.insert_team(teamtype integer, team character varying, uni integer) RETURNS uuid
    LANGUAGE plpgsql
    AS $$
DECLARE tmid uuid;
BEGIN
-- Insert into team
    INSERT INTO team (teamtypeid, teamname, uniid) VALUES (teamtype, team, uni)  RETURNING teamid INTO tmid;
	return tmid;
end;
$$;


ALTER FUNCTION public.insert_team(teamtype integer, team character varying, uni integer) OWNER TO postgres;

--
-- TOC entry 238 (class 1255 OID 17371)
-- Name: submit_code_file(character varying, uuid); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.submit_code_file(file character varying, vid uuid)
    LANGUAGE plpgsql
    AS $$
DECLARE subID int = 0;
begin
    -- insert submission into submission table
	INSERT INTO SUBMISSION (teamid) VALUES (vid) RETURNING submissionid INTO subID;
	
    -- insert file into file table
	INSERT INTO codefile(submissionid, filetext) VALUES (subid, file);
end;
$$;


ALTER PROCEDURE public.submit_code_file(file character varying, vid uuid) OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 206 (class 1259 OID 17290)
-- Name: codefile; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.codefile (
    submissionid integer,
    filetext character varying
);


ALTER TABLE public.codefile OWNER TO postgres;

--
-- TOC entry 213 (class 1259 OID 17381)
-- Name: group_run; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.group_run (
    group_run_id integer NOT NULL,
    startrun timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.group_run OWNER TO postgres;

--
-- TOC entry 212 (class 1259 OID 17379)
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
-- TOC entry 3073 (class 0 OID 0)
-- Dependencies: 212
-- Name: group_run_group_run_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.group_run_group_run_id_seq OWNED BY public.group_run.group_run_id;


--
-- TOC entry 209 (class 1259 OID 17314)
-- Name: logs; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.logs (
    runid integer,
    logtext character varying
);


ALTER TABLE public.logs OWNER TO postgres;

--
-- TOC entry 208 (class 1259 OID 17303)
-- Name: run; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.run (
    submissionid integer,
    runid integer NOT NULL,
    score integer,
    group_run_id integer
);


ALTER TABLE public.run OWNER TO postgres;

--
-- TOC entry 207 (class 1259 OID 17301)
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
-- TOC entry 3074 (class 0 OID 0)
-- Dependencies: 207
-- Name: run_runid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.run_runid_seq OWNED BY public.run.runid;


--
-- TOC entry 205 (class 1259 OID 17277)
-- Name: submission; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.submission (
    teamid uuid,
    submissionid integer NOT NULL,
    valid boolean DEFAULT false NOT NULL,
    submittime timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.submission OWNER TO postgres;

--
-- TOC entry 204 (class 1259 OID 17275)
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
-- TOC entry 3075 (class 0 OID 0)
-- Dependencies: 204
-- Name: submission_submissionid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.submission_submissionid_seq OWNED BY public.submission.submissionid;


--
-- TOC entry 203 (class 1259 OID 17263)
-- Name: team; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.team (
    teamid uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    uniid integer,
    teamtypeid integer,
    teamname character varying(100) NOT NULL,
    CONSTRAINT team_teamname_check CHECK (((teamname)::text <> ''::text))
);


ALTER TABLE public.team OWNER TO postgres;

--
-- TOC entry 211 (class 1259 OID 17339)
-- Name: teamtype; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.teamtype (
    teamtypeid integer NOT NULL,
    teamtypename character varying(100) NOT NULL,
    CONSTRAINT teamtype_teamname_check CHECK (((teamtypename)::text <> ''::text))
);


ALTER TABLE public.teamtype OWNER TO postgres;

--
-- TOC entry 210 (class 1259 OID 17337)
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
-- TOC entry 3076 (class 0 OID 0)
-- Dependencies: 210
-- Name: teamtype_teamtypeid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.teamtype_teamtypeid_seq OWNED BY public.teamtype.teamtypeid;


--
-- TOC entry 202 (class 1259 OID 17256)
-- Name: university; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.university (
    uniid integer NOT NULL,
    uniname character varying(100) NOT NULL,
    CONSTRAINT university_uniname_check CHECK (((uniname)::text <> ''::text))
);


ALTER TABLE public.university OWNER TO postgres;

--
-- TOC entry 201 (class 1259 OID 17254)
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
-- TOC entry 3077 (class 0 OID 0)
-- Dependencies: 201
-- Name: university_uniid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.university_uniid_seq OWNED BY public.university.uniid;


--
-- TOC entry 2914 (class 2604 OID 17384)
-- Name: group_run group_run_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.group_run ALTER COLUMN group_run_id SET DEFAULT nextval('public.group_run_group_run_id_seq'::regclass);


--
-- TOC entry 2911 (class 2604 OID 17306)
-- Name: run runid; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.run ALTER COLUMN runid SET DEFAULT nextval('public.run_runid_seq'::regclass);


--
-- TOC entry 2908 (class 2604 OID 17280)
-- Name: submission submissionid; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.submission ALTER COLUMN submissionid SET DEFAULT nextval('public.submission_submissionid_seq'::regclass);


--
-- TOC entry 2912 (class 2604 OID 17342)
-- Name: teamtype teamtypeid; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.teamtype ALTER COLUMN teamtypeid SET DEFAULT nextval('public.teamtype_teamtypeid_seq'::regclass);


--
-- TOC entry 2904 (class 2604 OID 17259)
-- Name: university uniid; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.university ALTER COLUMN uniid SET DEFAULT nextval('public.university_uniid_seq'::regclass);


--
-- TOC entry 2929 (class 2606 OID 17387)
-- Name: group_run group_run_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.group_run
    ADD CONSTRAINT group_run_pkey PRIMARY KEY (group_run_id);


--
-- TOC entry 2925 (class 2606 OID 17308)
-- Name: run run_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.run
    ADD CONSTRAINT run_pkey PRIMARY KEY (runid);


--
-- TOC entry 2923 (class 2606 OID 17284)
-- Name: submission submission_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.submission
    ADD CONSTRAINT submission_pkey PRIMARY KEY (submissionid);


--
-- TOC entry 2919 (class 2606 OID 17269)
-- Name: team team_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.team
    ADD CONSTRAINT team_pkey PRIMARY KEY (teamid);


--
-- TOC entry 2921 (class 2606 OID 17353)
-- Name: team team_teamname_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.team
    ADD CONSTRAINT team_teamname_key UNIQUE (teamname);


--
-- TOC entry 2927 (class 2606 OID 17345)
-- Name: teamtype teamtype_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.teamtype
    ADD CONSTRAINT teamtype_pkey PRIMARY KEY (teamtypeid);


--
-- TOC entry 2917 (class 2606 OID 17262)
-- Name: university university_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.university
    ADD CONSTRAINT university_pkey PRIMARY KEY (uniid);


--
-- TOC entry 2933 (class 2606 OID 17296)
-- Name: codefile codefile_submissionid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.codefile
    ADD CONSTRAINT codefile_submissionid_fkey FOREIGN KEY (submissionid) REFERENCES public.submission(submissionid);


--
-- TOC entry 2936 (class 2606 OID 17320)
-- Name: logs logs_runid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.logs
    ADD CONSTRAINT logs_runid_fkey FOREIGN KEY (runid) REFERENCES public.submission(submissionid);


--
-- TOC entry 2935 (class 2606 OID 17388)
-- Name: run run_group_run_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.run
    ADD CONSTRAINT run_group_run_id_fkey FOREIGN KEY (group_run_id) REFERENCES public.group_run(group_run_id);


--
-- TOC entry 2934 (class 2606 OID 17309)
-- Name: run run_submissionid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.run
    ADD CONSTRAINT run_submissionid_fkey FOREIGN KEY (submissionid) REFERENCES public.submission(submissionid);


--
-- TOC entry 2932 (class 2606 OID 17285)
-- Name: submission submission_teamid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.submission
    ADD CONSTRAINT submission_teamid_fkey FOREIGN KEY (teamid) REFERENCES public.team(teamid);


--
-- TOC entry 2931 (class 2606 OID 17346)
-- Name: team team_teamtypeid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.team
    ADD CONSTRAINT team_teamtypeid_fkey FOREIGN KEY (teamtypeid) REFERENCES public.teamtype(teamtypeid);


--
-- TOC entry 2930 (class 2606 OID 17270)
-- Name: team team_uniid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.team
    ADD CONSTRAINT team_uniid_fkey FOREIGN KEY (uniid) REFERENCES public.university(uniid);


-- Completed on 2021-10-17 18:29:38

--
-- PostgreSQL database dump complete
--

